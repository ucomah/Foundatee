import Foundation

public func measure(executionOf closure: (() -> Void), with label: String) -> TimeInterval {
    do {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        let begin = mach_absolute_time()
        closure()
        let diff = TimeInterval(mach_absolute_time() - begin) * TimeInterval(info.numer) / TimeInterval(info.denom)
        return diff / 1_000_000_000
    }
}

public func printMeasure(executionOf closure: (() -> Void), with label: String) {
    let timeInterval = measure(executionOf: closure, with: label)
    print("Time to evaluate \(label): \(timeInterval) seconds")
}
