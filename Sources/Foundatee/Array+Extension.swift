import Foundation

public protocol Int8ConvertibleType {
    var int8Value: Int8 { get }
}

extension Int8: Int8ConvertibleType {
    public var int8Value: Int8 { self }
}

extension Sequence where Element: Int8ConvertibleType {
    /// Builds string from array of int.
    public var string: String? {
        let result = compactMap { item -> Character? in
            let value = item.int8Value
            return value != 0 ? Character(UnicodeScalar(UInt8(value.int8Value))) : nil
        }
        return String(result)
    }
}

public extension MutableCollection where Element: Comparable {

    var any: Element? {
        guard isEmpty == false else { return nil }
        let buf: Self = self[randomPick: 1]
        return buf.first
    }

    /// Picks `n` random elements (partial Fisher-Yates shuffle approach)
    subscript <T>(randomPick n: Int) -> T where T: Collection, T.Element == Element {
        var copy = Array(self)
        for i in stride(from: count - 1, to: count - n - 1, by: -1) {
            copy.swapAt(i, Int(arc4random_uniform(UInt32(i + 1))))
        }
        return AnyCollection<Element>(copy.suffix(n)) as! T
    }
}

public extension Sequence where Element: Hashable {
    var unique: [Element] {
        var seen: [Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

public extension Sequence where Element: Equatable {
    func distinct<S: Sequence>(from source: S) -> [Element] where S.Element == Element {
        var unique = [Element]()
        for item in self {
            if !source.contains(item) {
                unique.append(item)
            }
        }
        return unique
    }
}

public extension Array where Element: Equatable {

    mutating func appendUnique(item: Element) {
        insertUnique(item: item, at: count)
    }

    mutating func appendUnique(itemsIn objs: [Element]) {
        insertUnique(itemsIn: objs, at: count)
    }

    mutating func insertUnique(item: Element, at index: Int) {
        if !contains(where: { $0 == item }) {
            insert(item, at: index)
        }
    }

    mutating func insertUnique(itemsIn objs: [Element], at index: Int) {
        let buf = objs.drop { (item) -> Bool in
            self.contains(where: { $0 == item })
        }
        insert(contentsOf: buf, at: index)
    }
}

extension Array {

    public subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        return index >= 0 && index < endIndex ? self[index] : defaultValue()
    }

    public subscript(safeIndex index: Int) -> Element? {
        return index >= 0 && index < endIndex ? self[index] : nil
    }
}

extension Array where Element : Equatable {
    
    public subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
        if bounds.lowerBound > count { return [] }
        let lower = Swift.max(0, bounds.lowerBound)
        let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
        return self[lower..<upper]
    }
  
    public subscript(safe lower: Int?, _ upper: Int?) -> ArraySlice<Element> {
        let lower = lower ?? 0
        let upper = upper ?? count
        if lower > upper { return [] }
        return self[safe: lower..<upper]
    }
}
