# NetworkCalculator

## Description
NetworkCalculator is a dynamic library that manages available host space in IP addresses and calculates subnetworks. The idea came from a task from one exam in the first course of the cisco CCNA course series.

## Example
code:
```C
// Create network with 24-bit mask
Network *network = CreateNetwork("192.168.0.0", 24);
if (network == NULL) {
	return 1;
}

char *description = CreateNetworkDescription(network);
printf("Parent network:\n%s\n\n", description);
// Free strings returned by the library's functions
free(description);

// The next block of code demonstrates how to use
// the library's functionality to split the network
// into two subnetworks with 100 and 50 hosts correspondingly.
unsigned int hosts[] = {100, 50, 0};
size_t count = sizeof(hosts) / sizeof(unsigned int) - 1;
Network **subnetworks = CreateSubnetworks(network, hosts);
if (subnetworks != NULL) {
	for (int i = 0; i < count; i++) {
		Network *subnetwork = subnetworks[i];
		description = CreateNetworkDescription(subnetwork);
		printf("Subnetwork %d:\n%s\n\n", i + 1, description);
		free(description);
	}
	free(subnetworks);
}

// Free all networks
free(network);
```
Output:
```
Parent network:
192.168.0.0/24
binary mask: 11111111.11111111.11111111.00000000
decimal mask: 255.255.255.0
192.168.0.1
...
192.168.0.254

Subnetwork 1:
192.168.0.0/25
binary mask: 11111111.11111111.11111111.10000000
decimal mask: 255.255.255.128
192.168.0.1
...
192.168.0.126

Subnetwork 2:
192.168.0.128/26
binary mask: 11111111.11111111.11111111.11000000
decimal mask: 255.255.255.192
192.168.0.129
...
192.168.0.190
```

## Installation
Open the .xcodeproj file in Xcode. Build the project. It will copy the headers to /usr/local/include and install the library in /usr/local/lib.

## Linking with existing projects
Add /usr/local/lib to your target's library search paths and /usr/local/include to the header search paths:
![enter image description here](https://raw.githubusercontent.com/Tymur77/NetworkCalculator/master/images/add-search-paths.png)

Then add ```#include <NetworkCalculator/NetworkCalculator.h>``` directive at the top of the file you want to use the library's functions in.

Finally, add libNetworkCalculator.dylib to your target's dependency list:
![enter image description here](https://raw.githubusercontent.com/Tymur77/NetworkCalculator/master/images/add-dependency.png)

## Documentation
[documentation](https://tymur77.github.io/NetworkCalculator/)
