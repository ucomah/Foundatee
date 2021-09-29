import Foundation

public protocol EnumDecodable: RawRepresentable, Decodable {
    static var defaultDecoderValue: Self? { get }
}

public extension EnumDecodable where RawValue: Decodable {

    static var defaultDecoderValue: Self? { nil }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(RawValue.self)
        if let primary = Self.init(rawValue: value) {
            self = primary
        } else if let value = Self.defaultDecoderValue {
            self = value
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "No default enum value provided"))
        }
    }
}

public protocol EnumEncodable: RawRepresentable, Encodable { }

public extension EnumEncodable where RawValue: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

public protocol EnumCodable: EnumEncodable & EnumDecodable {}

// MARK: - Unknown Case Representable

public protocol UnknownCaseRepresentable: RawRepresentable, CaseIterable where RawValue: Equatable {
    static var unknownCase: Self { get }
}

public extension UnknownCaseRepresentable {
    init(rawValue: RawValue) {
        let value = Self.allCases.first(where: { $0.rawValue == rawValue })
        self = value ?? Self.unknownCase
    }
}
