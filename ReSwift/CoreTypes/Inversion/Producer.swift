//
//  Producer.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// Override `run` as a callback hook on events coming in.
internal class Producer<Element>: Observable<Element> {
    internal override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Substate == Substate {
        // The SinkDisposer is returned to manage resources: if it is disposed, its managed resources are disposed, too.
        let disposer = SinkDisposer()
        let sinkAndSubscription = self.run(observer, cancel: disposer)
        disposer.set(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
        return disposer
    }

    internal func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        fatalError("Method not implemented: \(#function)")
    }
}

private final class SinkDisposer: Cancelable {
    private var _sink: Disposable?
    private var _subscription: Disposable?

    private enum State {
        case initial, set, disposed
    }

    private var state: State = .initial

    var isDisposed: Bool {
        return state == .disposed
    }

    func set(sink: Disposable, subscription: Disposable) {
        guard state == .initial else { preconditionFailure("SinkDisposer was set twice") }

        self._sink = sink
        self._subscription = subscription

        self.state = .set
    }

    func dispose() {
        guard state != .disposed else { return }

        guard let sink = self._sink else { preconditionFailure("Sink not set") }
        guard let subscription = self._subscription else { preconditionFailure("Subscription not set") }

        sink.dispose()
        subscription.dispose()

        self._sink = nil
        self._subscription = nil
    }
}
