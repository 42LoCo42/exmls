#include <erl_nif.h>
#include <stdint.h>

static ERL_NIF_TERM
compare(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
	(void) argc;

	int a = 0;
	int b = 0;

	if(!enif_get_int(env, argv[0], &a) || !enif_get_int(env, argv[1], &b)) {
		return enif_make_badarg(env);
	}

	int res = a == b ? 0 : a < b ? -1 : 1;
	return enif_make_int(env, res);
}

static ErlNifFunc funcs[] = {
	{"compare", 2, compare, 0},
};

ERL_NIF_INIT(Elixir.ExMLS.HPKE, funcs, NULL, NULL, NULL, NULL);
