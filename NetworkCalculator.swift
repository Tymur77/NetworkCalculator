import Foundation


class IPAddress {
    private var inner: __IPAddress
    static var zero: IPAddress { IPAddress(parts: [0,0,0,0])! }
    
    init?(parts: [UInt8]) {
        guard parts.count == 4 else { return nil }
        self.inner = (parts[0], parts[1], parts[2], parts[3])
    }
    
    init?(string: String) {
        self.inner = (0,0,0,0)
        let result = self.withUInt8Pointer { pointer in
            return string.withCString({ __IPAddressFromString(pointer, $0) })
        }
        guard result != 0 else { return nil }
    }
    
    var string: String {
        return self.withUInt8Pointer { pointer in
            let str = __stringIPAddress(pointer)!
            defer { str.deallocate() }
            return String(cString: str)
        }
    }
    
    var binary: String {
        return self.withUInt8Pointer { pointer in
            let str = __binaryIPAddress(pointer)!
            defer { str.deallocate() }
            return String(cString: str)
        }
    }
    
    func withUInt8Pointer<Result>(_ body: (UnsafeMutablePointer<UInt8>) throws -> Result)
    rethrows -> Result
    {
        return try body(&(self.inner.0))
    }
}


class Network {
    private let inner: UnsafeMutablePointer<__Network>
    
    deinit {
        inner.deallocate()
    }
    
    init?(address: String, mask: UInt8) {
        guard let ntwk = address.withCString({ __CreateNetwork($0, mask) }) else { return nil }
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
        var cp = hosts + [0]
        guard let subnetworks = __CreateSubnetworks(self.inner, &cp) else { return nil }
        defer { subnetworks.deallocate() }
        return (0..<hosts.count).map { Network(inner: subnetworks.advanced(by: $0).pointee!) }
    }
    
    var firstAddress: IPAddress {
        let result = IPAddress.zero
        result.withUInt8Pointer { __firstIPAddress($0, self.inner) }
        return result
    }
    
    var lastAddress: IPAddress {
        let result = IPAddress.zero
        result.withUInt8Pointer { __lastIPAddress($0, self.inner) }
        return result
    }
}
