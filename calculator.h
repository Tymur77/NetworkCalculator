#ifndef calculator_h
#define calculator_h

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "NetworkCalculator/NetworkCalculator.h"
#include "sort.h"
#include "misc.h"

#define EXPORT __attribute__((visibility("default")))

#define free(pointer) free(pointer); pointer = NULL

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"

#define BYTE_TO_BINARY(byte) \
((byte) & 0x80 ? '1' : '0'), \
((byte) & 0x40 ? '1' : '0'), \
((byte) & 0x20 ? '1' : '0'), \
((byte) & 0x10 ? '1' : '0'), \
((byte) & 0x08 ? '1' : '0'), \
((byte) & 0x04 ? '1' : '0'), \
((byte) & 0x02 ? '1' : '0'), \
((byte) & 0x01 ? '1' : '0')

#define DESCRIPTION_MAX_SIZE 1024

#define UCHAR_MASK(network) ((_Network *)network)->_mask

typedef struct {
    union {
        Network inner;
        struct {
            IPAddress address;
            IPAddress mask;
        };
    };
    unsigned char _mask;
} _Network;

#endif /* calculator_h */
