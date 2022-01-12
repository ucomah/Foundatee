import Foundation

@propertyWrapper
public struct Atomic<Value> {

    private var value: Value
    private let lock = NSLock()
    public var readLock = true

    public init(wrappedValue value: Value) {
        self.value = value
    }

    public init(wrappedValue value: Value, readLock: Bool = true) {
        self.value = value
        self.readLock = readLock
    }

    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue: newValue) }
    }

    public func load() -> Value {
        let isLocked = readLock ? lock.try() : false
        defer { if isLocked { lock.unlock() } }
        return value
    }

    public mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}
