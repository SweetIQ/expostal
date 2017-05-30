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
static sem_t *sem_libpostal_setup;
static sem_t *sem_libpostal_parser_setup;
static sem_t *sem_libpostal_language_classifier_setup;

