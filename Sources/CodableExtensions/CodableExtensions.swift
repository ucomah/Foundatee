import Foundation

public extension KeyedDecodingContainer {

    func decode<Transformer: DecodingContainerTransformer>(_ key: KeyedDecodingContainer.Key,
                                                           transformer: Transformer) throws -> Transformer.Output where Transformer.Input: Decodable {
        let decoded: Transformer.Input = try self.decode(key)
        return try transformer.transform(decoded)
    }

    func decodeIfPresent<Transformer: DecodingContainerTransformer>(_ key: KeyedDecodingContainer.Key,
                                                                    transformer: Transformer) throws -> Transformer.Output? where Transformer.Input: Decodable {
        guard let decoded: Transformer.Input = try self.decodeIfPresent(key) else { return nil }
        return try transformer.transform(decoded)
    }

    func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        return try self.decode(T.self, forKey: key)
    }

    func decodeIfPresent<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T: Decodable {
        return try self.decodeIfPresent(T.self, forKey: key)
    }
}

public extension KeyedEncodingContainer {

    mutating func encode<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output,
                                                                    forKey key: KeyedEncodingContainer.Key,
                                                                    transformer: Transformer) throws where Transformer.Input: Encodable {
        let transformed: Transformer.Input = try transformer.transform(value)
        try self.encode(transformed, forKey: key)
    }

    mutating func encodeIfPresent<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output?,
                                                                    forKey key: KeyedEncodingContainer.Key,
                                                                    transformer: Transformer) throws where Transformer.Input: Encodable {
        guard let _v = value else { return }
        let transformed: Transformer.Input = try transformer.transform(_v)
        try self.encodeIfPresent(transformed, forKey: key)
    }
}
