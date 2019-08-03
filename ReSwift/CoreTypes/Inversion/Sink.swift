//
//  Sink.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// It's a thing that can be disposed and forwards events to observers.
/// When disposed, it will not forward future events.
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
        self.isDisposed = true
        cancel.dispose()
    }
}
