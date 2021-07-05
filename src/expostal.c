#include <erl_nif.h>
#include <libpostal/libpostal.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>

#define HAS_DIRTY_SCHEDULER                                                    \
  (ERL_NIF_MAJOR_VERSION > 2 ||                                                \
   (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 10))

static pthread_mutex_t *expostal_lock;
static int is_setup = 0;

// make sure that the libpostal library is indeed already setup
int do_bootstrap() {
  if (is_setup == 0) {
    if (!libpostal_setup()) {
      fprintf(stderr, "Error loading libpostal\r\n");
      return 1;
    }

    if (!libpostal_setup_parser()) {
      fprintf(stderr, "Error loading libpostal parser\r\n");
      return 1;
    }

    if (!libpostal_setup_language_classifier()) {
      fprintf(stderr, "Error loading language classifier\r\n");
      return 1;
    }
    is_setup = 1;
  }
  return 0;
}

static ERL_NIF_TERM bootstrap(ErlNifEnv *env, int argc,
                              const ERL_NIF_TERM argv[]) {
  // make sure nothing else is trying to bootstrap while we run
  pthread_mutex_lock(expostal_lock);
  int retval = do_bootstrap();
  pthread_mutex_unlock(expostal_lock);
  if (retval == 0) {
    return enif_make_atom(env, "ok");
  } else {
    return enif_make_atom(env, "error");
  }
}

static ERL_NIF_TERM expand_address(ErlNifEnv *env, int argc,
                                   const ERL_NIF_TERM argv[]) {
  // libpostal is not threadsafe (see
  // https://github.com/openvenues/libpostal/issues/34)
  pthread_mutex_lock(expostal_lock);
  do_bootstrap();

  libpostal_normalize_options_t options = libpostal_get_default_options();
  ErlNifBinary address_bin;
  if (!enif_inspect_iolist_as_binary(env, argv[0], &address_bin)) {
    return enif_make_badarg(env);
  }
  char *address = strndup((char *)address_bin.data, address_bin.size);
  size_t num_expansions = 0;
  char **expansions =
      libpostal_expand_address(address, options, &num_expansions);

  ERL_NIF_TERM *expansion_terms = malloc(sizeof(ERL_NIF_TERM) * num_expansions);
  unsigned long i;
  for (i = 0; i < num_expansions; i++) {
    char *expansion = expansions[i];
    ERL_NIF_TERM expansion_term;
    unsigned char *expansion_term_bin =
        enif_make_new_binary(env, strlen(expansion), &expansion_term);
    strncpy((char *)expansion_term_bin, expansion, strlen(expansion));
    expansion_terms[i] = expansion_term;
  }

  ERL_NIF_TERM expansions_list_term =
      enif_make_list_from_array(env, expansion_terms, num_expansions);

  free(expansion_terms);
  free(address);

  pthread_mutex_unlock(expostal_lock);
  return expansions_list_term;
}

static ERL_NIF_TERM parse_address(ErlNifEnv *env, int argc,
                                  const ERL_NIF_TERM argv[]) {
  pthread_mutex_lock(expostal_lock);
  do_bootstrap();

  libpostal_address_parser_options_t options =
      libpostal_get_address_parser_default_options();
  ERL_NIF_TERM components = enif_make_new_map(env);
  ErlNifBinary address_bin;
  if (!enif_inspect_iolist_as_binary(env, argv[0], &address_bin)) {
    return enif_make_badarg(env);
  }

  char *address = strndup((char *)address_bin.data, address_bin.size);
  libpostal_address_parser_response_t *response =
      libpostal_parse_address(address, options);

  const char *component, *label;

  size_t i;
  for (i = 0; i < response->num_components; i++) {
    component = response->components[i];
    label = response->labels[i];
    ERL_NIF_TERM component_term;
    unsigned char *component_term_bin =
        enif_make_new_binary(env, strlen(component), &component_term);
    strncpy((char *)component_term_bin, component, strlen(component));

    enif_make_map_put(env, components, enif_make_atom(env, label),
                      component_term, &components);
  }

  enif_release_binary(&address_bin);
  libpostal_address_parser_response_destroy(response);
  free(address);

  pthread_mutex_unlock(expostal_lock);
  return components;
}

static ERL_NIF_TERM classify_language(ErlNifEnv *env, int argc,
                                      const ERL_NIF_TERM argv[]) {
  pthread_mutex_lock(expostal_lock);
  do_bootstrap();

  ErlNifBinary address_bin;
  if (!enif_inspect_iolist_as_binary(env, argv[0], &address_bin)) {
    return enif_make_badarg(env);
  }

  char *address = strndup((char *)address_bin.data, address_bin.size);
  libpostal_language_classifier_response_t *response =
      libpostal_classify_language(address);

  const char *language;

  size_t i;
  ERL_NIF_TERM *language_terms =
      malloc(sizeof(ERL_NIF_TERM) * response->num_languages);
  for (i = 0; i < response->num_languages; i++) {
    language = response->languages[i];
    ERL_NIF_TERM language_term;
    unsigned char *language_term_bin =
        enif_make_new_binary(env, strlen(language), &language_term);
    strncpy((char *)language_term_bin, language, strlen(language));
    language_terms[i] = language_term;
  }
  ERL_NIF_TERM probs_term = enif_make_double(env, *response->probs);

  ERL_NIF_TERM language_list_term =
      enif_make_list_from_array(env, language_terms, response->num_languages);

  ERL_NIF_TERM response_tuple_term =
      enif_make_tuple2(env, probs_term, language_list_term);

  free(language_terms);
  free(address);

  pthread_mutex_unlock(expostal_lock);
  return response_tuple_term;
}

// map our C functions to their Elixir equivalents
#if HAS_DIRTY_SCHEDULER
static ErlNifFunc funcs[] = {
    {"bootstrap", 0, bootstrap, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"classify_language", 1, classify_language, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"parse_address", 1, parse_address, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"expand_address", 1, expand_address, ERL_NIF_DIRTY_JOB_IO_BOUND}};
#else
static ErlNifFunc funcs[] = {{"bootstrap", 0, bootstrap},
                             {"classify_language", 1, classify_language},
                             {"parse_address", 1, parse_address},
                             {"expand_address", 1, expand_address}};
#endif

static int load(ErlNifEnv *env, void **priv, ERL_NIF_TERM info) {
  expostal_lock = malloc(sizeof(pthread_mutex_t));
  pthread_mutex_init(expostal_lock, NULL);
  return 0;
}

static int reload(ErlNifEnv *env, void **priv, ERL_NIF_TERM info) { return 0; }

static int upgrade(ErlNifEnv *env, void **priv, void **old_priv,
                   ERL_NIF_TERM info) {
  return load(env, priv, info);
}

static void unload(ErlNifEnv *env, void *priv) {
  libpostal_teardown();
  libpostal_teardown_parser();
  enif_free(priv);
}

ERL_NIF_INIT(Elixir.Expostal, funcs, &load, &reload, &upgrade, &unload)
