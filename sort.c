#include "sort.h"


int compareDecreasing(unsigned int *n1, unsigned int *n2)
{
     if (*n1 == *n2) return 0;
     else if (*n1 > *n2) return -1;
     else return 1;
}

Hosts sortHosts(unsigned int *hosts) {
    unsigned int *hosts_cpy = hosts;
    size_t count = 0;
    while (1) {
        if (*hosts++ == 0) break;
        count++;
    }
    if (count == 0) {
        return HostsZero;
    }
    // Multiplication overflows checks here
    size_t size = sizeof(unsigned int) * count;
    hosts = (unsigned int *)malloc(size);
    if (hosts == NULL) {
        return HostsZero;
    }
    memcpy(hosts, hosts_cpy, size);
    qsort(hosts, count, sizeof(unsigned int), (COMPARE_T)compareDecreasing);
    return (Hosts){hosts, count};
}
