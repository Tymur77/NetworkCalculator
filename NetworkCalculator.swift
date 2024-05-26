import Foundation


class IPAddress {
    private var inner: [UInt8]
    static var zero: IPAddress { IPAddress(parts: [0,0,0,0])! }
    
    init?(parts: [UInt8]) {
        guard parts.count == 4 else { return nil }
        self.inner = parts
    }
    
    init?(string: String) {
        self.inner = [0,0,0,0]
        let result = self.withUInt8Pointer { pointer in
            string.withCString { __IPAddressFromString(pointer, $0) }
        }
        guard result != 0 else { return nil }
    }
    
    init(copy other: IPAddress) {
        self.inner = other.inner
    }
    
    var string: String {
        let str = self.withUInt8Pointer { __stringIPAddress($0)! }
        defer { str.deallocate() }
        return String(cString: str)
    }
    
    var binary: String {
        let str = self.withUInt8Pointer { __binaryIPAddress($0)! }
        defer { str.deallocate() }
        return String(cString: str)
    }
    
    func withUInt8Pointer<Result>(_ body: (UnsafeMutablePointer<UInt8>) throws -> Result)
    rethrows -> Result
    {
        return try body(&self.inner)
    }
    
    subscript(index: Int) -> UInt8 {
        get { self.inner[index] }
        set { self.inner[index] = newValue }
    }
}


class Network {
    private let inner: UnsafeMutablePointer<__Network>
    lazy private(set) var address = {
        let address = self.inner.pointee.address
        return IPAddress(parts: [address.0, address.1, address.2, address.3])!
    }()
    lazy private(set) var mask = {
        let mask = self.inner.pointee.mask
        return IPAddress(parts: [mask.0, mask.1, mask.2, mask.3])!
    }()
    lazy private(set) var maskedBits = {
        var masked: UInt8 = 0
        for i in 0..<4 {
            masked += (self.mask[i] >> 7) & 1
            masked += (self.mask[i] >> 6) & 1
            masked += (self.mask[i] >> 5) & 1
            masked += (self.mask[i] >> 4) & 1
            masked += (self.mask[i] >> 3) & 1
            masked += (self.mask[i] >> 2) & 1
            masked += (self.mask[i] >> 1) & 1
            masked += (self.mask[i] >> 0) & 1
            guard self.mask[i] == 0xff else { break }
        }
        return masked
    }()
    
    deinit {
        inner.deallocate()
    }
    
    init?(address: String, mask: UInt8) {
        guard let ntwk = address.withCString({ __CreateNetwork($0, mask) }) else {
            return nil
        }
        self.inner = ntwk
    }
    
    private init(inner: UnsafeMutablePointer<__Network>) {
        self.inner = inner
    }
    
    var description: String {
        let str = __CreateNetworkDescription(self.inner)!
        defer { str.deallocate() }
        return String(cString: str)
    }
    
    func subnetworks(hosts: [UInt32]) -> [Network]? {
        var zeroed = hosts + [0]
        guard let subnetworks = __CreateSubnetworks(self.inner, &zeroed) else { return nil }
        defer { subnetworks.deallocate() }
        return (0..<hosts.count).map { Network(inner: subnetworks[$0]!) }
    }
    
    var firstAddress: IPAddress {
        let address = IPAddress.zero
        address.withUInt8Pointer { __firstIPAddress($0, self.inner) }
        return address
    }
    
    var lastAddress: IPAddress {
        let address = IPAddress.zero
        address.withUInt8Pointer { __lastIPAddress($0, self.inner) }
        return address
    }
}

