/// Inspired by:
/// https://stackoverflow.com/questions/27292255/how-to-loop-over-struct-properties-in-swift

import Foundation

public struct JSONOption: OptionSet {
    public let rawValue: UInt
    public static var allowsNull = JSONOption(rawValue: 1 << 0)
    /// Filter out all data types (or convert to string) which are not JSON compatible.
    public static var onlyCompatible = JSONOption(rawValue: 1 << 1)
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

public protocol Loopable {
    func allProperties() -> [String: Any]?
}

public extension Mirror {

    var toDictionary: [String: Any]? {
        var result: [String: Any] = [:]
        if displayStyle == .optional, let value = children.first?.value {
            return Mirror(reflecting: value).toDictionary
        }
        guard let style = displayStyle, style == .struct || style == .class else {
            return nil
        }
        for (property, value) in children {
            guard let property = property else {
                continue
            }
            if let lv = value as? Loopable {
                result[property] = lv.json()
            } else {
                result[property] = value
            }
        }
        if let superMirror = superclassMirror {
            if let superResult = superMirror.toDictionary {
                result.merge(superResult) { (current, _) -> Any in
                    return current // because we are digging into deep and don't want to skip overriden values
                }
            }
        }
        return result
    }
}

extension Loopable {

    public func allProperties() -> [String: Any]? {
        let mirror = Mirror(reflecting: self)
        let result = mirror.toDictionary
        return result
    }
}

extension Loopable {

    public func json(options: [JSONOption] = [.onlyCompatible]) -> [String: Any] {
        var json = [String: Any]()
        guard let props = self.allProperties() else {
            return json
        }
        for (property, value) in props {
            if let tmp = value as? [String: Any] {
                var dict = [String: Any]()
                for (k, v) in tmp {
                    if let loopableValue = (v as? Loopable)?.json() {
                        dict[k] = loopableValue
                    } else {
                        dict[k] = v
                    }
                }
                json[property] = dict
            } else if let tmp = value as? [Any] {
                var buf = [Any]()
                for item in tmp {
                    if let loopableValue = (item as? Loopable)?.json() {
                        buf.append(loopableValue)
                    } else {
                        buf.append(item)
                    }
                }
                json[property] = buf
            } else {
                if case Optional<Any>.none = value { // Any is nil
                    if options.contains(.allowsNull) {
                        json[property] = value
                    }
                } else if options.contains(.onlyCompatible) && (!(value is String) && !(value is Bool) && value as? Int == nil && value as? Float == nil) {
                    json[property] = String(describing: value)
                } else {
                    json[property] = value
                }
            }
        }
        let result = json.unwrapped()
        if options.contains(.allowsNull) {
            return result
        }
        return result.dropNull()
    }
}

public func unwrap<T>(_ any: T) -> Any {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional, let first = mirror.children.first else {
        return any
    }
    return unwrap(first.value)
}

public extension Array where Element == Any {
    func unwrapped() -> [Any] {
        return compactMap { unwrap($0) }
    }
    func dropNull() -> [Any] {
        return filter {
            if case Optional<Any>.none = $0 { return false } // swiftlint:disable:this all
            else { return true }
        }
    }
}

public extension Dictionary where Key == String, Value == Any {
    func unwrapped() -> [String: Any] {
        return compactMapValues { unwrap($0) }
    }
    func dropNull() -> [String: Any] {
        return filter {
            if case Optional<Any>.none = $0.value { return false } // swiftlint:disable:this all
            else { return true }
        }
    }
}
