import Foundation

infix operator <! : AssignmentPrecedence
infix operator >! : AssignmentPrecedence

public func <! <T: Comparable> (lhs: T, rhs: T) -> T {
    return lhs < rhs ? lhs : rhs
}

public func >! <T: Comparable> (lhs: T, rhs: T) -> T {
    return lhs > rhs ? lhs : rhs
}

public extension Double {
    /// Rounds to decimal places value
    func roundTo(places: UInt) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    static func random() -> Double {
        Double(arc4random()) / Double(UInt32.max)
    }

    /// Formatting double value to k and M
    /// 1000 = 1k
    /// 1100 = 1.1k
    /// 15000 = 15k
    /// 115000 = 115k
    /// 1000000 = 1m
    var shortStringRepresentation: String {
        if self.isNaN {
            return "NaN"
        }
        if self.isInfinite {
            return "\(self < 0.0 ? "-" : "+")∞"
        }
        let units = ["", "k", "M", "b"]
        var interval = self
        var i = 0
        while i < units.count - 1 {
            if abs(interval) < 1000.0 {
                break
            }
            i += 1
            interval /= 1000.0
        }
        // + 2 to have one digit after the comma, + 1 to not have any.
        // Remove the * and the number of digits argument to display all the digits after the comma.
        return "\(String(format: "%0.*g", Int(log10(abs(interval))) + 1, interval))\(units[i])"
    }

    func shortString(fractions: UInt = 0) -> String {
        if self.isNaN {
            return "NaN"
        }
        if self.isInfinite {
            return "\(self < 0.0 ? "-" : "+")∞"
        }
        let sign = (self < 0) ? "-" : ""
        let num = abs(self)
        let f = UInt(1)

        let value: Double
        let suffix: String
        switch self {
        case 1_000_000_000...:
            value = (num / 1_000_000_000).roundTo(places: f)
            suffix = "b"
        case 1_000_000...:
            value = (num / 1_000_000).roundTo(places: f)
            suffix = "m"
        case 1_000...:
            value = (num / 1_000).roundTo(places: f)
            suffix = "k"
        default:
            value = num
            suffix = ""
        }
        let s = String(format: "%.\(fractions)f", value)
        return "\(sign)\(s)\(suffix)"
    }
}

public extension IntegerLiteralType {

    /// Limits current Int value ti the number of digits with the way like 10 -> 9+, 100 -> 99+
    /// - Parameter digits: The number of digits allowed
    /// - Returns: String in format like `9+` etc.
    func limitedString(digits: Int8) -> String {
        guard (1 ..< Int8.max).contains(digits), self != 0 else {
            return String(self)
        }
        let count = Int(floor( log10(Float(abs(self))) ) + 1)
        if count > digits {
            return String(repeating: "9", count: Int(digits)) + "+"
        }
        return String(self)
    }
}

#if !swift(>=4.2)
public func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}
#endif
