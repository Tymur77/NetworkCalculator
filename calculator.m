#include "calculator.h"


EXPORT
char *stringIPAddress(IPAddress address) {
    char decimal[16] = {'\0'};
    sprintf(decimal, "%d.%d.%d.%d", address[0], address[1], address[2], address[3]);
    return strdup(decimal);
}


EXPORT
char *binaryIPAddress(IPAddress address) {
    char binary[36] = {'\0'};
    sprintf(binary + 0, BYTE_TO_BINARY_PATTERN".", BYTE_TO_BINARY(address[0]));
    sprintf(binary + 9, BYTE_TO_BINARY_PATTERN".", BYTE_TO_BINARY(address[1]));
    sprintf(binary + 18, BYTE_TO_BINARY_PATTERN".", BYTE_TO_BINARY(address[2]));
    sprintf(binary + 27, BYTE_TO_BINARY_PATTERN, BYTE_TO_BINARY(address[3]));
    return strdup(binary);
}


EXPORT
int IPAddressFromString(IPAddress address, const char *string) {
    if (string == NULL) {
        return 0;
    }
    int i;
    const char *start = string;
    char *end;
    IPAddress result;
    for (i = 0; i < 4; i++) {
        long x = strtol(start, &end, 10);
        if ((x == 0 && end == start) || x > 0xff || x < 0) {
            // If no conversion is possible (no valid digits are found),
            // or the converted number is out of bounds
            return 0;
        }
        result[i] = (unsigned char)x;
        if (*end == '\0') {
            if (i < 3) {
                return 0;
            }
        }
        start = end + 1;
    }
    copyIPAddress(address, result);
    return 1;
}


void IPAddressFromMask(IPAddress address, unsigned char mask) {
    IPAddress result = IPAddressZero;
    for (int i = 0; i < 4; i++) {
        if (mask < 8) {
            result[i] = 0xff << (8 - mask);
            break;
        } else {
            result[i] = 0xff;
            mask -= 8;
        }
    }
    copyIPAddress(address, result);
}


EXPORT
void firstIPAddress(IPAddress address, Network *network) {
    copyIPAddress(address, network->address);
    address[3] += 1;
}


EXPORT
void lastIPAddress(IPAddress address, Network *network) {
    address[0] = network->address[0] + ~network->mask[0];
    address[1] = network->address[1] + ~network->mask[1];
    address[2] = network->address[2] + ~network->mask[2];
    address[3] = network->address[3] + ~network->mask[3] - 1;
}


EXPORT
Network *CreateNetwork(const char *address, unsigned char mask) {
    if (mask > 30 || mask == 0) {
        return NULL;
    }
    IPAddress ip;
    if (!IPAddressFromString(ip, address)) {
        return NULL;
    }
    _Network *network = (_Network *)malloc(sizeof(_Network));
    if (network == NULL) {
        return NULL;
    }
    copyIPAddress(network->address, ip);
    IPAddressFromMask(network->mask, mask);
    // Zero-out all unmasked bits.
    network->address[0] = ip[0] & network->mask[0];
    network->address[1] = ip[1] & network->mask[1];
    network->address[2] = ip[2] & network->mask[2];
    network->address[3] = ip[3] & network->mask[3];
    network->_mask = mask;
    return (Network *)network;
}


EXPORT
char *CreateNetworkDescription(Network *network) {
    char info[DESCRIPTION_MAX_SIZE] = {'\0'};
    
    char *decimal = stringIPAddress(network->address);
    strlcat(info, decimal, sizeof(info));
    free(decimal);
    
    char mask_buffer[4] = {'\0'};
    sprintf(mask_buffer, "/%d", UCHAR_MASK(network));
    
    strlcat(info, mask_buffer, sizeof(info));
    
    strlcat(info, "\nbinary mask: ", sizeof(info));
    char *binary = binaryIPAddress(network->mask);
    strlcat(info, binary, sizeof(info));
    free(binary);
    
    strlcat(info, "\ndecimal mask: ", sizeof(info));
    decimal = stringIPAddress(network->mask);
    strlcat(info, decimal, sizeof(info));
    free(decimal);
    
    // First ip address
    IPAddress first;
    firstIPAddress(first, network);
    strlcat(info, "\n", sizeof(info));
    decimal = stringIPAddress(first);
    strlcat(info, decimal, sizeof(info));
    free(decimal);
    strlcat(info, "\n...\n", sizeof(info));
    
    // Last ip address
    IPAddress last;
    lastIPAddress(last, network);
    decimal = stringIPAddress(last);
    strlcat(info, decimal, sizeof(info));
    free(decimal);
    
    return strdup(info);
}


EXPORT
Network **CreateSubnetworks(Network *parent, unsigned int *hosts) {
    size_t count;
    unsigned char subnetsAreaShift;
    
    // Rule 1
    {
        // Hosts structure
        Hosts hs = sortHosts(hosts);
        if (hs.hosts == NULL) {
            return NULL;
        }
        hosts = hs.hosts;
        count = hs.count;
    }
    
    // Rule 2
    {
        // maxHosts = 2^(32-mask)-2
        // n - number of hosts in the largest subnetwork
        // n <= maxHosts
        unsigned int maxHostCapacity = ((unsigned int)1 << (32 - UCHAR_MASK(parent))) - 2;
        if (hosts[0] > maxHostCapacity) {
            free(hosts);
            return NULL;
        }
    }
    
    // Rule 3
    {
        subnetsAreaShift = bitsForHosts(hosts[0]);
    }
    
    // Rule 4
    {
        unsigned int maxSubnetCapacity = (unsigned int)1 << (32 - UCHAR_MASK(parent) - subnetsAreaShift);
        if (count > maxSubnetCapacity) {
            free(hosts);
            return NULL;
        }
    }
    
    _Network **result = (_Network **)malloc(sizeof(_Network *) * count);
    if (result == NULL) {
        free(hosts);
        return NULL;
    }
    
//    uint32_t subnetsArea;
//    ((unsigned char *)(&subnetsArea))[0] = parent->address[3];
//    ((unsigned char *)(&subnetsArea))[1] = parent->address[2];
//    ((unsigned char *)(&subnetsArea))[2] = parent->address[1];
//    ((unsigned char *)(&subnetsArea))[3] = parent->address[0];
    IPAddress increment = IPAddressZero;
    
    for (size_t i = 0; i < count; i++) {
        unsigned int n = hosts[i];
        
        // The first subnetwork has the same address as the parent network
        if (i > 0) {
            incrementIPAddress(increment);
        }
        
        _Network *subnetwork = (_Network*)malloc(sizeof(_Network));
        if (subnetwork == NULL) {
            free(hosts);
            free(result);
            return NULL;
        }
        
        unsigned char bits = bitsForHosts(n);
        IPAddress mask;
        IPAddressFromMask(mask, 32 - bits);
        copyIPAddress(subnetwork->mask, mask);
        
        subnetwork->_mask = 32 - bits;
        
        copyIPAddress(subnetwork->address, parent->address);
        overlapNetwork(subnetwork, increment, subnetsAreaShift);
        
        result[i] = subnetwork;
    }
    
    free(hosts);
    return (Network **)result;
}
