#include <erl_nif.h>
#include <hpke.h>

#define HPKE_TAG_LEN 16

#define ASIZ(x) (sizeof(x) / sizeof(x[0]))

#define BAD(msg)                                                               \
	{                                                                          \
		fprintf(stderr, "%s:%d: BADARG: %s\n", __FILE__, __LINE__, msg);       \
		return enif_make_badarg(env);                                          \
	}

#define OK(x) enif_make_tuple2(env, ok_atom, x)

#define ERR(msg)                                                               \
	{                                                                          \
		fprintf(stderr, "%s:%d: ERROR: %s\n", __FILE__, __LINE__, msg);        \
		return enif_make_tuple2(                                               \
			env, err_atom, enif_make_string(env, msg, ERL_NIF_LATIN1)          \
		);                                                                     \
	}

#define b2aref(x)                                                              \
	{ .b = x.data, .s = x.size, }

#define getbin(name, term)                                                     \
	ErlNifBinary name = {0};                                                   \
	if(!enif_inspect_binary(env, term, &name)) BAD(#name ": not a binary");

// helpers =====================================================================

ERL_NIF_TERM ok_atom;
ERL_NIF_TERM err_atom;

ERL_NIF_TERM sk_atom;
ERL_NIF_TERM pk_atom;

ERL_NIF_TERM mode_atom;
ERL_NIF_TERM kem_atom;
ERL_NIF_TERM kdf_atom;
ERL_NIF_TERM aead_atom;

ERL_NIF_TERM enc_atom;
ERL_NIF_TERM ctx_atom;

static int load(ErlNifEnv* env, void** data, ERL_NIF_TERM info) {
	(void) data;
	(void) info;

	ok_atom  = enif_make_atom(env, "ok");
	err_atom = enif_make_atom(env, "err");

	sk_atom = enif_make_atom(env, "sk");
	pk_atom = enif_make_atom(env, "pk");

	mode_atom = enif_make_atom(env, "mode");
	kem_atom  = enif_make_atom(env, "kem");
	kdf_atom  = enif_make_atom(env, "kdf");
	aead_atom = enif_make_atom(env, "aead");

	enc_atom = enif_make_atom(env, "enc");
	ctx_atom = enif_make_atom(env, "ctx");

	return 0;
}

static ERL_NIF_TERM get_suite(ErlNifEnv* env, ERL_NIF_TERM map, hpke_t* suite) {
	ERL_NIF_TERM mode_term;
	ERL_NIF_TERM kem_id_term;
	ERL_NIF_TERM kdf_id_term;
	ERL_NIF_TERM aead_id_term;

	if(!enif_get_map_value(env, map, mode_atom, &mode_term))
		BAD("suite: no mode");
	if(!enif_get_map_value(env, map, kem_atom, &kem_id_term))
		BAD("suite: no kem");
	if(!enif_get_map_value(env, map, kdf_atom, &kdf_id_term))
		BAD("suite: no kdf");
	if(!enif_get_map_value(env, map, aead_atom, &aead_id_term))
		BAD("suite: no aead");

	uint mode;
	uint kem_id;
	uint kdf_id;
	uint aead_id;

	if(!enif_get_uint(env, mode_term, &mode)) BAD("suite: mode: not uint");
	if(!enif_get_uint(env, kem_id_term, &kem_id)) BAD("suite: kem: not uint");
	if(!enif_get_uint(env, kdf_id_term, &kdf_id)) BAD("suite: kdf: not uint");
	if(!enif_get_uint(env, aead_id_term, &aead_id))
		BAD("suite: aead: not uint");

	suite->mode    = mode;
	suite->kem_id  = kem_id;
	suite->kdf_id  = kdf_id;
	suite->aead_id = aead_id;

	return 0;
}

// exports =====================================================================

// kem_id: uint -> %{sk: binary, pk: binary}
static ERL_NIF_TERM
gen_kp(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	// get args ================================================================
	uint kem_id = 0;
	if(!enif_get_uint(env, argv[0], &kem_id)) BAD("kem_id: not uint");

	// generate key ============================================================
	uint32_t sk_size = 0;
	uint32_t pk_size = 0;
	HPKE_Keysize(kem_id, &sk_size, &pk_size, NULL);

	ErlNifBinary sk = {0};
	ErlNifBinary pk = {0};
	enif_alloc_binary(sk_size, &sk);
	enif_alloc_binary(pk_size, &pk);
	if(HPKE_Keygen(kem_id, sk.data, pk.data) < 0) ERR("keygen");

	// create result map =======================================================
	ERL_NIF_TERM keys[] = {
		sk_atom,
		pk_atom,
	};
	ERL_NIF_TERM vals[] = {
		enif_make_binary(env, &sk),
		enif_make_binary(env, &pk),
	};

	ERL_NIF_TERM map = 0;
	enif_make_map_from_arrays(env, keys, vals, ASIZ(keys), &map);
	return OK(map);
}

// kem: uint
// sk: binary
// -> pk: binary
static ERL_NIF_TERM
drv_kp(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	// get args ================================================================
	uint kem_id = 0;
	if(!enif_get_uint(env, argv[0], &kem_id)) BAD("kem_id: not uint");
	getbin(sk, argv[1]);

	// allocate public key
	uint32_t pk_size = 0;
	HPKE_Keysize(kem_id, NULL, &pk_size, NULL);

	ErlNifBinary pk = {0};
	enif_alloc_binary(pk_size, &pk);

	// derive public key
	HPKE_Derive(kem_id, sk.data, pk.data);
	return OK(enif_make_binary(env, &pk));
}

// suite: %{mode: uint, kem: uint, kdf: uint, aead: uint}
// pk: binary
// info: string
// TODO: psk, psk_id
// -> %{enc: binary, ctx: binary}
static ERL_NIF_TERM
setup_s(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	// get args ================================================================
	hpke_t       suite = {0};
	ERL_NIF_TERM res   = get_suite(env, argv[0], &suite);
	if(res != 0) return res;

	getbin(pk, argv[1]);
	getbin(info, argv[2]);

	// create enc binary =======================================================
	uint32_t enc_size = 0;
	HPKE_Keysize(suite.kem_id, NULL, &enc_size, NULL);

	ErlNifBinary enc = {0};
	if(!enif_alloc_binary(enc_size, &enc)) ERR("alloc enc");

	// create context binary ===================================================
	ErlNifBinary ctx = {0};
	if(!enif_alloc_binary(sizeof(hpke_ctx_t), &ctx)) ERR("alloc ctx");

	hpke_array_ref_t empty    = {0};
	hpke_array_ref_t info_ref = b2aref(info);

	if(HPKE_SetupS(
		   suite,
		   pk.data,
		   info_ref,
		   empty,
		   empty,
		   enc.data,
		   (hpke_ctx_t*) ctx.data
	   ) < 0)
		ERR("setup_s");

	// create result map =======================================================
	ERL_NIF_TERM keys[] = {
		enc_atom,
		ctx_atom,
	};
	ERL_NIF_TERM vals[] = {
		enif_make_binary(env, &enc),
		enif_make_binary(env, &ctx),
	};

	ERL_NIF_TERM map = 0;
	enif_make_map_from_arrays(env, keys, vals, ASIZ(keys), &map);
	return OK(map);
}

// suite: %{mode: uint, kem: uint, kdf: uint, aead: uint}
// enc: binary
// sk: binary
// info: string
// -> ctx: binary
static ERL_NIF_TERM
setup_r(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	// get args ================================================================
	hpke_t       suite = {0};
	ERL_NIF_TERM res   = get_suite(env, argv[0], &suite);
	if(res != 0) return res;

	getbin(enc, argv[1]);
	getbin(sk, argv[2]);
	getbin(info, argv[3]);

	// create ctx binary =======================================================
	ErlNifBinary ctx = {0};
	if(!enif_alloc_binary(sizeof(hpke_ctx_t), &ctx)) ERR("alloc ctx");

	hpke_array_ref_t empty    = {0};
	hpke_array_ref_t info_ref = b2aref(info);

	if(HPKE_SetupR(
		   suite,
		   enc.data,
		   sk.data,
		   info_ref,
		   empty,
		   empty,
		   (hpke_ctx_t*) ctx.data
	   ) < 0)
		ERR("setup_r");

	return OK(enif_make_binary(env, &ctx));
}

// ctx: binary
// aad: string
// msg: string
// -> ct: binary
static ERL_NIF_TERM seal(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	// get args ================================================================
	getbin(ctx, argv[0]);
	getbin(aad, argv[1]);
	getbin(msg, argv[2]);

	// seal ====================================================================
	hpke_array_ref_t aad_ref = b2aref(aad);
	hpke_array_ref_t msg_ref = b2aref(msg);

	ErlNifBinary ct = {0};
	if(!enif_alloc_binary(msg.size + HPKE_TAG_LEN, &ct)) ERR("alloc ct");

	if(HPKE_Seal((hpke_ctx_t*) ctx.data, aad_ref, msg_ref, ct.data) < 0)
		ERR("seal");

	return OK(enif_make_binary(env, &ct));
}

// ctx: binary
// aad: string
// ct: binary
// -> msg: binary
static ERL_NIF_TERM open(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	// get args ================================================================
	getbin(ctx, argv[0]);
	getbin(aad, argv[1]);
	getbin(ct, argv[2]);

	// open ====================================================================
	hpke_array_ref_t aad_ref = b2aref(aad);
	hpke_array_ref_t ct_ref  = b2aref(ct);

	ErlNifBinary msg = {0};
	if(!enif_alloc_binary(ct.size - HPKE_TAG_LEN, &msg)) ERR("alloc msg");

	if(HPKE_Open((hpke_ctx_t*) ctx.data, aad_ref, ct_ref, msg.data) < 0)
		ERR("open");

	return OK(enif_make_binary(env, &msg));
}

static ErlNifFunc funcs[] = {
	{"nif_gen_kp", 1, gen_kp, 0},
	{"nif_drv_kp", 2, drv_kp, 0},
	{"nif_setup_s", 3, setup_s, 0},
	{"nif_setup_r", 4, setup_r, 0},
	{"seal", 3, seal, 0},
	{"open", 3, open, 0},
};

ERL_NIF_INIT(Elixir.ExMLS.HPKE, funcs, load, NULL, NULL, NULL);
