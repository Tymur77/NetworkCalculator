#ifndef ipaddress_h
#define ipaddress_h

#include <Foundation/Foundation.h>
#include "datatypes.h"

/*!
 @header Working with IP addresses
 @discussion This section describes how to obtain IP addresses
 from other data types.
 @unsorted
 */


/*!
 @abstract IPAddress for 0.0.0.0
 */
#define IPAddressZero (IPAddress){0, 0, 0, 0}


/*!
 @abstract Copies all values of one ip address into another
 @param address1 destination
 @param address2 source
 */
#define copyIPAddress(address1, address2) \
address1[0] = address2[0]; \
address1[1] = address2[1]; \
address1[2] = address2[2]; \
address1[3] = address2[3]


/*!
 @abstract Populates an ip address with values from a string
 @param address ip address, which will hold the extracted values
 @param string C-style string, reprsenting the ip address, for example, "192.168.0.1"
 @return On success returns a non-zero value.
 @discussion
 The delimiter between the parts of the ip address may be any character,
 greater than the maximum digit of base 10 (which is 9), or an arbitrary character.
 */
int IPAddressFromString(IPAddress address, const char *string) NS_REFINED_FOR_SWIFT;


/*!
 @abstract Produces the first ip address in a network
 @param address ip address, which will hold the values of the first ip address in the network
 @param network network, holding the information necessary
 for the calculation of the first ip address. Ideally created with CreateNetwork.
 @discussion For example, network "192.168.0.0"
 with mask "255.255.0.0" will have the first ip address equal to "192.168.0.1".
 */
void firstIPAddress(IPAddress address, Network *network) NS_REFINED_FOR_SWIFT;


/*!
 @abstract Produces the last ip address in a network
 @param address ip address, which will hold the values of the last ip address in the network
 @param network network, holding the information necessary
 for the calculation of the last ip address. Ideally created with CreateNetwork.
 @discussion For example, network "192.168.0.0"
 with mask "255.255.255.0" will have the first last address equal to "192.168.0.254".
 Note that the directed broadcast address is not the last ip address.
 */
void lastIPAddress(IPAddress address, Network *network) NS_REFINED_FOR_SWIFT;


#endif /* ipaddress_h */
