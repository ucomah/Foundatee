import Foundation

/// According to:
/// https://www.swiftbysundell.com/articles/published-properties-in-swift/

@propertyWrapper
public struct Witness<Value> {
    public var projectedValue: Witness { self }
    public var wrappedValue: Value { didSet { valueDidChange() } }
    
    private var observations = MutableReference(
        value: LinkedList<(Value) -> Void>()
    )

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

fileprivate extension Witness {
    func valueDidChange() {
        for closure in observations.value {
            closure(wrappedValue)
        }
    }
}

open class Disposable {
    
    private var closure: (() -> Void)?

    public init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    deinit {
        dispose()
    }

    public func dispose() {
        closure?()
        closure = nil
    }
}

extension Witness {
    public func observe(with closure: @escaping (Value) -> Void) -> Disposable {
        // To further mimmic Combine's behaviors, we'll call
        // each observation closure as soon as it's attached to
        // our property:
        closure(wrappedValue)

        let node = observations.value.append(closure)

        return Disposable { [weak observations] in
            observations?.value.remove(node)
        }
    }
}

// MARK: - Reference

class Reference<Value> {
    
    fileprivate(set) var value: Value

    init(value: Value) {
        self.value = value
    }
}

class MutableReference<Value>: Reference<Value> {
    func update(with value: Value) {
        self.value = value
    }
}
