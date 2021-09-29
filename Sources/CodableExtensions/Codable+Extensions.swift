import Foundation

public extension KeyedDecodingContainer where K: CodingKey {
    /// Decodes specified item type by iterating through `keysVariations` until finding a valid value.
    /// - Parameters:
    ///   - type: Target item type.
    ///   - keys: An array of Coding Keys to be iterated through.
    func decodeIfPresent<T: Decodable>(_ type: T.Type, keysVariations keys: [KeyedDecodingContainer<K>.Key]) throws -> T? {
        for k in keys {
            if let some = try decodeIfPresent(T.self, forKey: k) {
                return some
            }
        }
        return nil
    }
}
