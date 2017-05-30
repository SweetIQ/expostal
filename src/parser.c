#include <libpostal/libpostal.h>
#include <erl_nif.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "helper.c"

static ERL_NIF_TERM
parse_address(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  pthread_mutex_lock(&libpostal_mutex);
  size_t i;
  libpostal_address_parser_options_t options = libpostal_get_address_parser_default_options();
  ERL_NIF_TERM components = enif_make_new_map(env);
  ErlNifBinary address_bin;
  if (!enif_inspect_iolist_as_binary(env, argv[0], &address_bin))
  {
    return enif_make_badarg(env);
  }
  char *address = strndup((char*) address_bin.data, address_bin.size);
  libpostal_address_parser_response_t *response = libpostal_parse_address(address, options);

  const char *component, *label;

  for (i = 0; i < response->num_components; i++)
  {
    component = response->components[i];
    label = response->labels[i];
    ERL_NIF_TERM component_term;
    unsigned char *component_term_bin = enif_make_new_binary(env, strlen(component), &component_term);
    strncpy(component_term_bin, component, strlen(component));

    enif_make_map_put(env, components,
                      enif_make_atom(env, label),
                      component_term,
                      &components);
  }

  enif_release_binary(&address_bin);
  libpostal_address_parser_response_destroy(response);
  free(address);
  pthread_mutex_unlock(&libpostal_mutex);
  return components;
}

static ErlNifFunc funcs[] = {
    {"parse_address", 1, parse_address}};

static int
load(ErlNifEnv *env, void **priv, ERL_NIF_TERM info)
{
  pthread_mutex_lock(&libpostal_mutex);
  if (!is_libpostal_setup) {
    if (!libpostal_setup())
    {
      fprintf(stderr, "Error loading libpostal");
      pthread_mutex_unlock(&libpostal_mutex);
      return 1;
    }
    is_libpostal_setup = 1;
  }

  if (!is_libpostal_parser_setup) {
    if (!libpostal_setup_parser())
    {
      fprintf(stderr, "Error loading libpostal parser");
      pthread_mutex_unlock(&libpostal_mutex);
      return 1;
    }
    is_libpostal_parser_setup = 1;
  }

  libpostal_reference_count++;
  pthread_mutex_unlock(&libpostal_mutex);
  return 0;
}

static int
reload(ErlNifEnv *env, void **priv, ERL_NIF_TERM info)
{
  return 0;
}

static int
upgrade(ErlNifEnv *env, void **priv, void **old_priv, ERL_NIF_TERM info)
{
  return load(env, priv, info);
}

static void
unload(ErlNifEnv *env, void *priv)
{
  pthread_mutex_lock(&libpostal_mutex);
  libpostal_reference_count--;
  if (libpostal_reference_count == 0)
  {
    libpostal_teardown();
    libpostal_teardown_parser();
  }
  enif_free(priv);
  pthread_mutex_unlock(&libpostal_mutex);
}

ERL_NIF_INIT(Elixir.Expostal.Parser, funcs, &load, &reload, &upgrade, &unload)
