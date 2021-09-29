import Foundation

infix operator +/

/// Returns String with left String appended with right one as a path component
public func +/ (left: String, right: String) -> String {
    return left + "." + right
}

public extension String {

    /// To check text field or String is blank or not
    var isBlank: Bool {
        let trimmed = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }

    /// Checks if string contains letters only
    var isWordsOnly: Bool {
        return fits(CharacterSet.unionSets(from: [.letters, .whitespaces]))
    }

    /// Checks if string contains digits only
    var isDigitsOnly: Bool {
        return fits(CharacterSet.decimalDigits)
    }

    func fits(_ set: CharacterSet) -> Bool {
        for chr in self.utf8 {
            if !set.contains(UnicodeScalar(chr)) {
                return false
            }
        }
        return true
    }

    /// Creates alphanumeric string with specified length
    static func randomAlphaNumericString(length: UInt) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            randomString += String(allowedChars[randomNum])
        }

        return randomString
    }

    /// Converts string like "thisIsSomeErrorName" to "This Is Some Error Name"
    var naturalLanguageString: String {
        var newStringArray: [String] = []
        let space = " "
        for character in self {
            if String(character) == String(character).uppercased() {
                newStringArray.append(space)
            }
            newStringArray.append(String(character))
        }
        let resultArr = newStringArray.joined().trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: space)
        return resultArr.joined(separator: space).capitalized
    }

    /**
     Creates alphanumeric string with random length.
     - parameter maxValue: indicates the maximum number of characters.
     */
    static func randomString(maxValue: UInt?) -> String {
        return String.randomAlphaNumericString(length: UInt(arc4random_uniform(UInt32(maxValue ?? UInt.max))))
    }

    var utf8Representation: Data {
        return self.data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data()
    }

    var length: Int {
        return self.count
    }

    subscript (i: Int) -> String {
        let ch = self[self.index(self.startIndex, offsetBy: i)]
        return String(ch)
    }

    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        #if swift(>=4.0)
        let s = self[start ..< end]
        return String(s)
        #else
        return self[Range(start ..< end)]
        #endif
    }

    mutating func addExtensionIfNeeded(_ ext: String) {
        var newExt = ""
        if self.contains(".") {
            newExt = self.components(separatedBy: ".").last ?? ""
        }
        if newExt.isBlank {
            if self.last != "." {
                self += "."
            }
            self += ext
        }
    }

    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    mutating func reachLength(_ length: Int, trailing: String = " ") -> String {
        if self.length > length {
            #if swift(>=4.0)
            let r = self.index(self.startIndex, offsetBy: length)
            let s = self[..<r]
            return String(s)
            #else
            return self.substring(to: self.index(self.startIndex, offsetBy: length))
            #endif
        } else {
            if self.length < length {
                let count = length - self.length
                for _ in 0 ... count {
                    self.append(trailing)
                }
            }
            return self
        }
    }

    var boolValue: Bool? {
        switch self.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }

    func removingCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }

    func removingCharacters(from: String) -> String {
        return removingCharacters(from: CharacterSet(charactersIn: from))
    }

    var digitsOnly: String {
        return self.removingCharacters(from: CharacterSet.decimalDigits.inverted)
    }
}

public extension CharacterSet {
    /**
     Unites several Character Sets to one..
     
     - parameter from: the array of Character Sets
     - returns: Character set which contains all sets from array.
     */
    static func unionSets(from array: [CharacterSet]) -> CharacterSet {
        var cs = CharacterSet()
        for curSet in array {
            cs.formUnion(curSet)
        }
        return cs
    }
}
