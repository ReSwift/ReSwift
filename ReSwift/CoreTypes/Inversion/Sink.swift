//
//  Sink.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// A Sink represents a disposable connection to an observer. Think of it as a cancelable
/// wrapper that forwards events.
///
/// - `observer` receives events as long as `isDisposed == false`.
/// - `dispose` forwards resource cleanup commands to the `cancel` handler.
///
/// ## Subclassing Notes
///
/// Subclass `Sink` for operators to inherit the resource cleanup.
/// Call `forward(state:)` to pass on events to eventual observers.
///
/// You could also delegate to a `Sink` instance instead of subclassing, but
/// the convenience of inheriting `Disposable` would then be lost.
internal class Sink<Observer: ObserverType>: Disposable {
    internal let observer: Observer
    internal let cancel: Cancelable

    init(observer: Observer, cancel: Cancelable) {
        self.observer = observer
        self.cancel = cancel
    }

    final func forward(state: Observer.Substate) {
        guard !isDisposed else { return }
        self.observer.on(state)
    }

    // TODO: Use NSLock/atomic values for thread safety
    private var isDisposed: Bool = false

    func dispose() {
        guard !isDisposed else { return }
        self.isDisposed = true
        cancel.dispose()
    }
}
