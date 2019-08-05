//
//  Observable+create.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

extension Observable {
    /// Starting point of events, aka state updates.
    ///
    /// The `producer` block is first invoked when an actual connection is made.
    /// Until you finish the subscription, no callbacks are being made.
    internal static func create(_ producer: @escaping (AnyObserver<Substate>) -> Disposable) -> Observable<Substate> {
        return ObservableEventSource(producer: producer)
    }
}

/// The source of an event sequence that all operators will eventually delegate to.
///
/// Overrides the abstract `Producer.run` to actually connect the event creation sequence to an
/// observer.
///
/// `ObservableEventSource.producer` is a closure that is configured upon creation to produce `.on`
/// events; they are passed to the observer that is eventually set via `subscribe`.
final private class ObservableEventSource<Substate>: Producer<Substate> {
    typealias EventProducer = (_ consumer: AnyObserver<Substate>) -> Disposable

    internal let producer: EventProducer

    init(producer: @escaping EventProducer) {
        self.producer = producer
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Substate == Substate {
        let sink = ObservableEventSourceSink(observer: observer, cancel: cancel)
        let subscription = sink.subscribeObserver(self)
        return (sink, subscription)
    }
}

/// In short, objects of this type are adapters between `ObservableEventSource.EventProducer`
/// and an a compatible `ObserverType` that perform no additional actions; their sole
/// reason to exist is memory management of the `observer` and `cancel` associated with `Sink`s.
///
/// Since this type is a `Sink`, it keeps a strong reference to both its `observer`
/// and `cancel` handler. It will be released when the connection itself is released.
/// The connection from event source to observer will be released when `cancel` is disposed,
/// which ultimately is a `Producer`'s `SinkDisposer`.
final private class ObservableEventSourceSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Substate = Observer.Substate

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ state: Substate) {
        self.observer.on(state)
    }

    func subscribeObserver(_ eventSource: ObservableEventSource<Substate>) -> Disposable {
        let erasedObserver = AnyObserver(self)
        return eventSource.producer(erasedObserver)
    }
}
