#ifndef datatypes_h
#define datatypes_h

#include <Foundation/Foundation.h>

/*!
 @header Data types
 @discussion To calculate subnetworks NetworkCalculator operates on some basic data types,
 which are described below.
 @unsorted
 */


/*!
 @typedef IPAddress
 @abstract Represents an IPv4 address
 @discussion An array of 4 unsigned 8-bit integers is convenient
 for storing each of the parts of an ip address, separated by a dot.
 */
NS_REFINED_FOR_SWIFT typedef unsigned char IPAddress[4];


/*!
 @abstract Represents an IPv4 network
 @discussion
 When creating a network using CreateNetwork, the function automatically
 zeroes out all bits, that are not part of the network's address
 (are not masked by the network's mask). If you choose to fill out the fields
 manually, be sure to assign a valid value to address. Otherwise, calculating
 subnetworks will yield unexpeted results.
 
 mask has type IPAddress, which allows passing it directly to functions, that
 generate string representations, ommitting the step of converting
 the number of masked bits.
 */
NS_REFINED_FOR_SWIFT typedef struct {
    /*!
     @field address network's ip address
     */
    IPAddress address;
    /*!
     @field mask network's mask
     */
    IPAddress mask;
} Network;


#endif /* datatypes_h */
