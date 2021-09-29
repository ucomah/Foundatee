import Foundation

public extension ProcessInfo {
    var isTestTarget: Bool {
        return environment["XCTestConfigurationFilePath"] != nil
    }
}
