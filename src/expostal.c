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
  ERL_NIF_TERM components = enif_make_new_map(env);
  char *address = malloc(sizeof(char) * MAX_ADDR_LEN);
  libpostal_address_parser_options_t options = libpostal_get_address_parser_default_options();
  enif_get_string(env, argv[0], address, MAX_ADDR_LEN, ERL_NIF_LATIN1);
  libpostal_address_parser_response_t *response = libpostal_parse_address(address, options);


  for (i = 0; i < response->num_components; i++) {
    char *component = response->components[i];
    char *label = response->labels[i];

    enif_make_map_put(env, components,
                      enif_make_atom(env, label),
                      enif_make_string(env, component, ERL_NIF_LATIN1),
                      &components);
  }

  libpostal_address_parser_response_destroy(response);

  free(address);
  return components;
}

static ErlNifFunc funcs[] = {
  { "parse_address_c", 1,  parse_address }
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
