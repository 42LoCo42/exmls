#include <erl_nif.h>
#include <hpke.h>
#include <stdint.h>
#include <stdlib.h>

#define ASIZ(x) (sizeof(x) / sizeof(x[0]))

ERL_NIF_TERM sk_atom;
ERL_NIF_TERM pk_atom;

static int load(ErlNifEnv* env, void** data, ERL_NIF_TERM info) {
	(void) data;
	(void) info;

	sk_atom = enif_make_atom(env, "sk");
	pk_atom = enif_make_atom(env, "pk");
	return 0;
}

static ERL_NIF_TERM
gen_kp(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	uint kem_id = 0;
	if(!enif_get_uint(env, argv[0], &kem_id)) {
		return enif_make_badarg(env);
	}

	uint32_t sk_size  = 0;
	uint32_t pk_size  = 0;
	uint32_t sec_size = 0;
	HPKE_Keysize(kem_id, &sk_size, &pk_size, &sec_size);

	ErlNifBinary sk = {0};
	ErlNifBinary pk = {0};
	enif_alloc_binary(sk_size, &sk);
	enif_alloc_binary(pk_size, &pk);
	HPKE_Keygen(kem_id, sk.data, pk.data);

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
	return map;
}

static ErlNifFunc funcs[] = {
	{"gen_kp", 1, gen_kp, 0},
};

ERL_NIF_INIT(Elixir.ExMLS.HPKE, funcs, load, NULL, NULL, NULL);
