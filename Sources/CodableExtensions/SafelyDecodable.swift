import Foundation

/// Decode JSON object omitting throw funciton
/// Example usage:
/// `try JSONDecoder().decode([SafelyDecodable<YourType>].self, from: data)`
public struct SafelyDecodable<T: Decodable>: Decodable {

    public let result: Result<T, Error>

    public init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}

@propertyWrapper
public struct SafelyDecodableArray<Value: Decodable>: Decodable {

    public var wrappedValue: [Value] = []

    public private(set) var error: Error?

    private struct _None: Decodable {}

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let res = Result(catching: { try container.decode(Value.self) })
            do {
                wrappedValue.append(try res.get())
            } catch {
                self.error = error
                // item is silently ignored.
                _ = try? container.decode(_None.self)
            }
        }
    }
}

public typealias ArrayIgnoringFailure<Value: Decodable> = SafelyDecodableArray<Value>

// MARK: - Extensions

extension KeyedDecodingContainer {

    public func decodeSafely<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        self.decodeSafely(T.self, forKey: key)
    }

    public func decodeSafely<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        try? decode(SafelyDecodable<T>.self, forKey: key).result.get()
    }

    public func decodeSafelyIfPresent<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        try? decodeIfPresent(SafelyDecodable<T>.self, forKey: key)?.result.get()
    }

    public func decodeSafelyIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        self.decodeSafelyIfPresent(T.self, forKey: key)
    }
}

extension KeyedDecodingContainer {

    public func decodeSafelyArray<T: Decodable>(of type: T.Type, forKey key: KeyedDecodingContainer.Key) -> [T] {
        let array = try? decode([SafelyDecodable<T>].self, forKey: key)
        return array?.compactMap { try? $0.result.get() } ?? []
    }

    public func decodeSafelyArray<T: Decodable>(forKey key: KeyedDecodingContainer.Key) -> [T] {
        self.decodeSafelyArray(of: T.self, forKey: key)
    }

    public func decodeSafelyArrayIfPresent<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> [T]? {
        try? decodeIfPresent([SafelyDecodable<T>].self, forKey: key)?.compactMap { try? $0.result.get() }
    }

    public func decodeSafelyArrayIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        self.decodeSafelyIfPresent(T.self, forKey: key)
    }
}

extension JSONDecoder {
    public func decodeSafelyArray<T: Decodable>(of type: T.Type, from data: Data) -> [T] {
        let arr = try? decode([SafelyDecodable<T>].self, from: data)
        return arr?.compactMap { try? $0.result.get() } ?? []
    }
}
