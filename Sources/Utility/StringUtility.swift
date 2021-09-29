import Foundation

extension String {

    public var isBase64EncodedString: Bool {
        let base64Regex = "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", base64Regex)
        return predicate.evaluate(with: self)
    }
}
