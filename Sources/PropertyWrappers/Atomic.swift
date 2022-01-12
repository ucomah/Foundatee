import Foundation
#if canImport(Combine)
import Combine
#endif

@propertyWrapper
public class Atomic<Value> {

    private var value: Value
    private let lock = NSLock()
    public var readLock = true
    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, *)
    private lazy final var publisher = PassthroughSubject<Value, Never>()
    @available(iOS 13.0, macOS 10.15, *)
    public var projectedValue: AnyPublisher<Value, Never> {
        publisher.eraseToAnyPublisher()
    }
    #endif
    
    public init(wrappedValue value: Value) {
        self.value = value
    }

    public init(wrappedValue value: Value, readLock: Bool = true) {
        self.value = value
        self.readLock = readLock
    }

    public var wrappedValue: Value {
        get { load() }
        set { store(newValue: newValue) }
    }

    public func load() -> Value {
        let isLocked = readLock ? lock.try() : false
        defer { if isLocked { lock.unlock() } }
        return value
    }

    public func store(newValue: Value) {
        let isLocked = self.lock.try()
        defer { if isLocked { self.lock.unlock() } }
        value = newValue
        #if canImport(Combine)
        if #available(iOS 13.0, macOS 10.15, *) {
            publisher.send(newValue)
        }
        #endif
    }
}
