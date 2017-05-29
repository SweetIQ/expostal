#include <libpostal/libpostal.h>
#include <erl_nif.h>
#include <stdio.h>

#define PARSER_USAGE "Usage: parse_address(address[, options])"
#define MAX_ADDR_LEN 255

typedef struct {
} expostal_priv;

static ERL_NIF_TERM
parse_address(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  size_t i;
  libpostal_address_parser_options_t options = libpostal_get_address_parser_default_options();
  ERL_NIF_TERM components = enif_make_new_map(env);
  ErlNifBinary address_bin;
  if (!enif_inspect_iolist_as_binary(env, argv[0], &address_bin)) {
    return enif_make_badarg(env);
  }
  libpostal_address_parser_response_t *response = libpostal_parse_address(address_bin.data, options);

  char *component, *label;
  ErlNifBinary component_bin;

  for (i = 0; i < response->num_components; i++) {
    component = response->components[i];
    label = response->labels[i];

    enif_alloc_binary(strlen(component), &component_bin);
    strcpy(component_bin.data, component);

    enif_make_map_put(env, components,
                      enif_make_atom(env, label),
                      enif_make_binary(env, &component_bin),
                      &components);
  }

  libpostal_address_parser_response_destroy(response);

  enif_release_binary(&address_bin);

  return components;
}

static ErlNifFunc funcs[] = {
  { "parse_address", 1,  parse_address }
};

static int
load(ErlNifEnv* env, void** priv, ERL_NIF_TERM info) {
  expostal_priv* data = enif_alloc(sizeof(expostal_priv));
  if (data == NULL) {
    return 1;
  }

  *priv = (void*) data;

  if (!libpostal_setup() || !libpostal_setup_parser()) {
    fprintf(stderr, "Error loading libpostal");
    return 1;
  }
  return 0;
}

static int
reload(ErlNifEnv* env, void** priv, ERL_NIF_TERM info) {
  return 0;
}

static int
upgrade(ErlNifEnv* env, void** priv, void** old_priv, ERL_NIF_TERM info) {
  return load(env, priv, info);
}

static void
unload(ErlNifEnv* env, void* priv) {
  libpostal_teardown();
  libpostal_teardown_parser();
  enif_free(priv);
}

ERL_NIF_INIT(Elixir.Expostal, funcs, &load, &reload, &upgrade, &unload)
