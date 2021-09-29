#if canImport(Combine)
import Foundation
import Combine

@available(iOS 13.0, *)
public struct Signal<Output, Failure: Error>: Combine.Publisher {

    private class Subscription: Combine.Subscription {

        let producer: (AnySubscriber<Output, Failure>) -> Combine.AnyCancellable
        let subscriber: AnySubscriber<Output, Failure>

        var cancellable: Combine.AnyCancellable?

        init(producer: @escaping (AnySubscriber<Output, Failure>) -> Combine.AnyCancellable, subscriber: AnySubscriber<Output, Failure>) {
            self.producer = producer
            self.subscriber = subscriber
        }

        func request(_ demand: Combine.Subscribers.Demand) {
            cancellable = producer(subscriber)
        }

        func cancel() {
            cancellable?.cancel()
        }
    }

    private let producer: (AnySubscriber<Output, Failure>) -> Combine.AnyCancellable

    public init(_ producer: @escaping (AnySubscriber<Output, Failure>) -> Combine.AnyCancellable) {
        self.producer = producer
    }

    public func receive<S>(subscriber: S) where S: Combine.Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(producer: producer, subscriber: AnySubscriber(subscriber))
        subscriber.receive(subscription: subscription)
    }
}

#endif
