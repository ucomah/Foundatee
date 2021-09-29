import Foundation

@available(iOS 10.0, *)
public extension Bundle {

    subscript(infoString key: String) -> String {
        let s = self.infoDictionary?[key] as? String
        assert(s != nil, "INFO.plist String not found!")
        return s ?? ""
    }

    var isAppExtension: Bool {
        let bundleUrl: URL = bundleURL
        let bundlePathExtension: String = bundleUrl.pathExtension
        return bundlePathExtension == "appex"
    }

    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
