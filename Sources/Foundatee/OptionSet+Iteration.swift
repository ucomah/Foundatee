import Foundation

/// https://stackoverflow.com/questions/32102936/how-do-you-enumerate-optionsettype-in-swift
public struct OptionSetIterator<Element: OptionSet>: IteratorProtocol where Element.RawValue == Int {
    private let value: Element

    public init(element: Element) {
        self.value = element
    }

    private lazy var remainingBits = value.rawValue
    private var bitMask = 1

    public mutating func next() -> Element? {
        while remainingBits != 0 {
            defer { bitMask = bitMask &* 2 }
            if remainingBits & bitMask != 0 {
                remainingBits = remainingBits & ~bitMask
                return Element(rawValue: bitMask)
            }
        }
        return nil
    }
}

public extension OptionSet where Self.RawValue == Int {
    func makeIterator() -> OptionSetIterator<Self> {
        return OptionSetIterator(element: self)
    }
}

public extension OptionSet where Self.RawValue == Int, Self: Sequence {
    var count: Int {
        return compactMap { _ in 1 }.reduce(0, +)
    }

}
