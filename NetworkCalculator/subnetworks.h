#ifndef subnetworks_h
#define subnetworks_h

#include <Foundation/Foundation.h>
#include "datatypes.h"

/*!
 @header Creating subnetworks
 @discussion This section describes how to create an IPv4 network,
 generate detailed information about networks, and use programming interfaces, which manage
 available host space to split a network into multiple subnetworks (this process is called subnetworking).
 @unsorted
 */


/*!
 @abstract Allocates a new Network structure and fills it with the provided information
 @param address ip address of the network
 @param mask number of masked bits (1-30)
 @return If the operation was successful, this function returns the newly allocated Network structure,
 otherwise NULL.
 @discussion The library does not perform any cleaning work of freeing allocated structures.
 You must do so after you are done using the network.
 */
Network *CreateNetwork(const char *address, unsigned char mask) NS_REFINED_FOR_SWIFT;


/*!
 @abstract Creates a string description of a network
 @param network network, whose detailed information is needed
 @result Returns a pointer to a C-style string with the description of the network.
 @attributeblock Memory After you are done using the string, call free.
 */
char *CreateNetworkDescription(Network *network) NS_REFINED_FOR_SWIFT;

/*!
 @abstract Allocates new subnetworks
 @param parent parent network
 @param hosts array with the number of elements equal to the number of subnetworks plus 1 (the last number must be 0).
 Every element of the array is an integer, representing the number of hosts in the corresponding subnetwork.
 @return If the operation was successful, this function returns a pointer to the newly allocated Network structures,
 otherwise NULL. In the first case, you must free the pointer and each of the subnetworks after you are done using them.
 @discussion The function first identifies the minimum number of bits, which will give enough capacity for all hosts of the largest
 subnetwork (including the address of the subnetwork and its directed broadcast address). The next step is calculating,
 how many bits are left for numbering the subnetworks. It's worth noting, that the mask of the parent network is taken into account
 when doing that, and the numbering is done in the decreasing order, where the largest subnetwork receives the lowest address.
 If there are not enough unmasked bits in the parent network to produce the requested quantity of subnetworks and hosts, then
 the operation is deemed unsuccessful.
 
 Example:
 For parent network "192.168.0.1" with mask "255.255.255.0" create two subnetworks with 50 and 100 hosts correspondingly.
 The first resulting subnetwork is "192.168.0.0" with mask "255.255.255.128".
 The second resulting subnetwork is "192.168.0.128" with mask "255.255.255.192"
 
 Note that unlike parameter hosts, the yielded array does not end with a NULL pointer. When iterating through it,
 the number of elements is exactly one less than that of hosts.
 */
Network **CreateSubnetworks(Network *parent, unsigned int *hosts) NS_REFINED_FOR_SWIFT;


#endif /* subnetworks_h */
