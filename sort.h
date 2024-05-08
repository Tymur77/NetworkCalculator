#ifndef sort_h
#define sort_h

#include "calculator.h"

#define HostsZero (Hosts){NULL, 0}

int compareDecreasing(unsigned int *_Nonnull, unsigned int *_Nonnull);

typedef int (*_Nonnull COMPARE_T)(const void *_Nonnull, const void *_Nonnull);

typedef struct {
    unsigned int *_Nullable hosts;
    size_t count;
} Hosts;

Hosts sortHosts(unsigned int *_Nonnull);

#endif /* sort_h */
