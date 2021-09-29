import Foundation

public func _is_Simulator() -> Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
}
