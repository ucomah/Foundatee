import Foundation

public extension Data {
    var binaryArray: [UInt8] {
        #if swift(>=3.0)
            #if swift(<5.0)
            let binArr = self.withUnsafeBytes {
                Array(UnsafeBufferPointer<UInt8>(start: $0, count: self.count / MemoryLayout<UInt8>.size))
            }
            return binArr
            #else
            return self.withUnsafeBytes {
                let ptr = $0.bindMemory(to: UInt8.self)
                if let addr = ptr.baseAddress {
                    return Array(UnsafeBufferPointer<UInt8>(start: addr, count: self.count / MemoryLayout<UInt8>.size))
                }
                return []
            }
            #endif
        #else
            return Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(self.bytes), count: self.length))
        #endif
    }
}
