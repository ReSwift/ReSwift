//
//  Observable.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// Represents a push style state update sequence.
protocol ObservableType {
    associatedtype Substate
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Substate == Substate
}

extension ObservableType {
    func subscribe(_ observer: @escaping (Substate) -> Void) -> Disposable {
        let observer = AnyObserver(observer: observer)
        return self.asObservable().subscribe(observer)
    }
}

extension ObservableType {
    func asObservable() -> Observable<Substate> {
        return Observable.create { observer in
            return self.subscribe(observer)
        }
    }
}

/// Type-erased `ObervableType`.
///
/// You can only get `Observable` instances through the `create` static factory, as used by the `Store`.
internal class Observable<Substate>: ObservableType {
    internal init() {
        // no-op
    }

    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Substate == Substate {
        fatalError("Method not implemented: \(#function)")
    }

    /// Optimization hook for multiple `select` calls in succession. Is overwritten by the `Select` type.
    internal func composeSelect<SelectedSubstate>(_ transform: @escaping (Substate) -> SelectedSubstate) -> Observable<SelectedSubstate> {
        return ReSwift.select(source: self, transform: transform)
    }

    func asObservable() -> Observable<Substate> {
        return self
    }
}
