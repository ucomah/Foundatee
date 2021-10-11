import Foundation
#if canImport(Combine)
import Combine
#endif

open class FolderWatchdog {

    public typealias FolderChangeClosure = (() -> Void)

    // MARK: Properties
    /// A file descriptor for the monitored directory
    private var monitoredDirectoryFileDescriptor: CInt = -1
    /// A dispatch queue used for sending file changes in the directory
    private let queue = DispatchQueue(label: "com.directoryWatchdog.queue", attributes: DispatchQueue.Attributes.concurrent)
    /// A dispatch source to monitor a file descriptor
    private var watchdogSource: DispatchSourceFileSystemObject?
    /// URL for the directory to be monitored
    private var URL: URL
    /// A closure responsible for responding to `FolderWatchdog` updates
    public var onChages: FolderChangeClosure?


    // MARK: Lifecycle

    /// Initializer.
    ///
    /// - Parameters:
    ///   - URL: URL for the directory to be monitored
    ///   - closure: A closure responsible for responding to `FolderWatchdog` updates
    public init(URL: URL, _ closure: FolderChangeClosure? = nil) {
        self.URL = URL
        self.onChages = closure
    }

    // MARK: Monitoring

    /// Starts monitoring
    public func start() {
        if watchdogSource == nil && monitoredDirectoryFileDescriptor == -1 {
            monitoredDirectoryFileDescriptor = open(URL.path, O_EVTONLY)

            watchdogSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredDirectoryFileDescriptor, eventMask: [.write], queue: queue)

            watchdogSource?.setEventHandler { [weak self] in
                self?.handleCange()
            }

            watchdogSource?.setCancelHandler {
                close(self.monitoredDirectoryFileDescriptor)
                self.monitoredDirectoryFileDescriptor = -1
                self.watchdogSource = nil
            }

            watchdogSource?.resume()
        }
    }

    /// Stops monitoring
    public func stop() {
        watchdogSource?.cancel()
    }
    
    fileprivate func handleCange() {
        self.onChages?()
    }
}

#if canImport(Combine)

@available(iOS 13.0, *)
open class DirectoryWatchdog: FolderWatchdog {
    
    @available(iOS 13.0, *)
    var changePublisher: AnyPublisher<Void, Error> {
        changeSubject.eraseToAnyPublisher()
    }

    private let changeSubject = PassthroughSubject<Void, Error>()

    public init(url: URL) {
        super.init(URL: url, nil)
    }
    
    override func handleCange() {
        super.handleCange()
        changeSubject.send(completion: .finished)
    }
}
#endif // canImport(Combine)
