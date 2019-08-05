//
//  Producer.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// Implements the abstract `Observable.subscribe` to release resources upon disposal.
/// Delegates the actual grunt work of connecting an event sequence to an observer to
/// subclasses that implement `run(_:)`.
///
/// Notable examples:
///
/// - `Observable.create` uses `ObservableEventSource` to produce events at the beginning of
///    an event sequence. This is the root of all subscriptions.
/// - Operators like `Select` take an existing sequence and connect their transformers to it
///   in `run(_:)`, *producing* a resulting sequence.
internal class Producer<Substate>: Observable<Substate> {
    internal override func subscribe<Observer: ObserverType>(_ observer: Observer)
        -> Disposable where Observer.Substate == Substate
    {
        // SinkDisposer is the ultimate `Cancelable` in the object hierarchy.
        let disposer = SinkDisposer()
        let sinkAndSubscription = self.run(observer, cancel: disposer)
        disposer.set(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
        return disposer
    }

    internal func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
        ) -> (sink: Disposable, subscription: Disposable)
    {
        fatalError("Method not implemented: \(#function)")
    }
}

/// See `Sink` for details; in short, a sink encapsulates event forwarding until it is disposed.
/// `SinkDisposer` in turn keeps a sink and the resulting subscription in memory together
/// for as long as the event sequence is retained.
///
/// This is at the root of observable event sequences. When the initial sequence is disposed,
/// this object will release the strong references to `sink` and `subscription` once, invoking
/// their `dispose()` callbacks in return.
private final class SinkDisposer: Cancelable {
    private var sink: Disposable?
    private var subscription: Disposable?

    private enum State {
        case initial, set, disposed
    }

    private var state: State = .initial

    var isDisposed: Bool {
        return state == .disposed
    }

    func set(sink: Disposable, subscription: Disposable) {
        guard state == .initial else { preconditionFailure("SinkDisposer was set twice") }
        self.state = .set

        self.sink = sink
        self.subscription = subscription
    }

    func dispose() {
        guard state != .disposed else { return }
        self.state = .disposed

        guard let sink = self.sink else { preconditionFailure("Sink not set") }
        guard let subscription = self.subscription else { preconditionFailure("Subscription not set") }

        sink.dispose()
        subscription.dispose()

        self.sink = nil
        self.subscription = nil
    }
}
