import Foundation

@propertyWrapper
public struct QueueSafe<Value> {

    private var _value: Value
    private var queue = DispatchQueue.init(label: "safe.value.queue", qos: .default, attributes: .concurrent)

    public init(wrappedValue value: Value) {
        _value = value
    }

    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue: newValue) }
    }

    public func load() -> Value {
        var value: Value!
        queue.sync {
            value = _value
        }
        return value
    }

    public mutating func store(newValue: Value) {
        var this = self
        queue.async(flags: .barrier) {
            this._value = newValue
        }
        self = this
    }
}
