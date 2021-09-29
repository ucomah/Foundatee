import Dispatch
import Foundation

public extension DispatchQueue {
    static var userInteractive: DispatchQueue { return DispatchQueue.global(qos: .userInteractive) }
    static var userInitiated: DispatchQueue { return DispatchQueue.global(qos: .userInitiated) }
    static var utility: DispatchQueue { return DispatchQueue.global(qos: .utility) }
    static var background: DispatchQueue { return DispatchQueue.global(qos: .background) }

    func asyncAfter(seconds: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + seconds, execute: closure)
    }

    func after(_ seconds: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(seconds: seconds, execute: closure)
    }
}

public extension OperationQueue {
    var isMainQueue: Bool {
        return self == OperationQueue.main
    }
    static var isCurrentQueueMain: Bool {
        return OperationQueue.current?.isMainQueue ?? false
    }
    static var serialQueue: OperationQueue {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }
}

/// Executes `closure` in provided `queue` and waits in current queue until it's finished.
public func dispatchGroupIn(queue qq: DispatchQueue, with closure: @escaping (() -> Void)) {
    if let currQueue = OperationQueue.current?.underlyingQueue, currQueue.isEqual(qq) {
        closure()
        return
    }
    let gg = DispatchGroup()
    gg.enter()
    qq.async { () -> Void in
        closure()
        gg.leave()
    }
    _ = gg.wait(timeout: DispatchTime.distantFuture)
}

/// Executes `closure` in main queue and waits in current queue until it's finished.
public func dispatchGroupInMainQueue(with closure: @escaping (() -> Void)) {
    dispatchGroupIn(queue: DispatchQueue.main, with: closure)
}
