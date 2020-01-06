//
//  Observer.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// Receives a state update.
protocol ObserverType {
    associatedtype Substate
    func on(_ state: Substate)
}

/// Type-erased `ObserverType` that forwards events.
internal final class AnyObserver<Substate>: ObserverType {
    private let observer: (Substate) -> Void

    init(observer: @escaping (Substate) -> Void) {
        self.observer = observer
    }

    init<Observer: ObserverType>(_ observer: Observer) where Observer.Substate == Substate {
        self.observer = observer.on
    }

    func on(_ substate: Substate) {
        self.observer(substate)
    }
}
