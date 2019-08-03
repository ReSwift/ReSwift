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


internal struct AnyObserver<Substate>: ObserverType {
    private let actionHandler: (Substate) -> Void

    init(actionHandler: @escaping (Substate) -> Void) {
        self.actionHandler = actionHandler
    }

    init<Observer: ObserverType>(_ observer: Observer) where Observer.Substate == Substate {
        self.actionHandler = observer.on
    }

    func on(_ substate: Substate) {
        self.actionHandler(substate)
    }
}
