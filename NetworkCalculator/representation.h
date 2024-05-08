#ifndef representation_h
#define representation_h


/*!
 @header Repserenting IP addresses
 @discussion This section lists programming interfaces for generating different
 forms of representaion of IP addresses.
 @unsorted
 */


/*!
 @abstract Creates a decimal string representation of an ip address
 @param address ip address, which will be used for creating
 the string representation
 @result Returns a pointer to a C-style string, representing the ip address.
 @attributeblock Memory After you are done using the string, call free.
 */
char *stringIPAddress(IPAddress address);


/*!
 @abstract Creates a binary string representation of an ip address
 @param address ip address, which will be used for creating
 the string representation
 @result Returns a pointer to a C-style string, representing the ip address.
 @attributeblock Memory After you are done using the string, call free.
 */
char *binaryIPAddress(IPAddress address);


#endif /* representation_h */
