#include "misc.h"


unsigned char bitsForHosts(unsigned int n) {
    unsigned char bits = 1;
    while (bits < 31) {
        unsigned int hostCapacity = ((unsigned int)1 << ++bits) - 2;
        if (hostCapacity >= n) break;
    }
    return bits;
}


void incrementIPAddress(IPAddress address) {
    for (int i = 3; i >= 0; i--) {
        if (address[i] == 0xff) {
            address[i] = 0;
        } else {
            address[i] += 1;
            break;
        }
    }
}


void overlapNetwork(void *network, IPAddress overlapping, unsigned char subnetsAreaShift) {
    unsigned char used = 0;
    unsigned char nbyte = 3;
    
#define NetworkAddress(network) ((Network *)network)->address
    
    for (int i = 3; i >= 0; i--) {
        if (subnetsAreaShift == 0) {
            NetworkAddress(network)[i] |= overlapping[nbyte] >> used;
            
            // If the whole byte was overlapped,
            // then a redundant logical OR operation between the byte and 0x0
            // will be performed.
            NetworkAddress(network)[i] |= overlapping[--nbyte] << (8 - used);
        }
        else if (subnetsAreaShift < 8) {
            NetworkAddress(network)[i] |= overlapping[nbyte] << subnetsAreaShift;
            used = 8 - subnetsAreaShift;
            subnetsAreaShift = 0;
        } else {
            subnetsAreaShift -= 8;
        }
    }
}
