/*
 * Libpostal is not thread safe... Hence we will need to handle
 * thread-safety here.
 */

#pragma once
#include <libpostal/libpostal.h>
#include <pthread.h>
#include <fcntl.h>
#include <semaphore.h>

static pthread_mutex_t libpostal_mutex = PTHREAD_MUTEX_INITIALIZER;

static int is_libpostal_setup = 0;
static int is_libpostal_parser_setup = 0;
static int is_libpostal_language_classifier_setup = 0;

static int libpostal_reference_count = 0;
