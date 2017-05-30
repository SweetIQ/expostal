#include <libpostal/libpostal.h>
#include <erl_nif.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "helper.c"


static ERL_NIF_TERM
expand_address(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  libpostal_normalize_options_t options = libpostal_get_default_options();
  ErlNifBinary address_bin;
  if (!enif_inspect_iolist_as_binary(env, argv[0], &address_bin))
  {
    return enif_make_badarg(env);
  }
  char *address = strndup((char*) address_bin.data, address_bin.size);
  size_t num_expansions = 0;
  char **expansions  = libpostal_expand_address(address, options, &num_expansions);

  ERL_NIF_TERM *expansion_terms = malloc(sizeof(ERL_NIF_TERM) * num_expansions);
  for (int i = 0; i < num_expansions; i++)
  {
    char *expansion = expansions[i];
    ERL_NIF_TERM expansion_term;
    unsigned char *expansion_term_bin = enif_make_new_binary(env, strlen(expansion), &expansion_term);
    strncpy(expansion_term_bin, expansion, strlen(expansion));
    expansion_terms[i] = expansion_term;
  }

  ERL_NIF_TERM expansions_list_term = enif_make_list_from_array(env, expansion_terms, num_expansions);

  free(expansion_terms);
  free(address);
  return expansions_list_term;
}

static ErlNifFunc funcs[] = {
  { "expand_address", 1, expand_address }
};

static int
load(ErlNifEnv* env, void** priv, ERL_NIF_TERM info) 
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
    if (!libpostal_setup_language_classifier())
    {
      fprintf(stderr, "Error loading libpostal parser");
      pthread_mutex_unlock(&libpostal_mutex);
      return 1;
    }
    is_libpostal_language_classifier_setup = 1;
  }

  libpostal_reference_count++;
  pthread_mutex_unlock(&libpostal_mutex);
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
  pthread_mutex_lock( &libpostal_mutex );
  libpostal_reference_count--;
  if (libpostal_reference_count == 0)
  {
    libpostal_teardown();
    libpostal_teardown_language_classifier();
  }
  enif_free(priv);
  pthread_mutex_unlock( &libpostal_mutex );
}

ERL_NIF_INIT(Elixir.Expostal.Expand, funcs, &load, &reload, &upgrade, &unload)
