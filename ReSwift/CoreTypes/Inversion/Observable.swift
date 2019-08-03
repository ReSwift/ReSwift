//
//  Observable.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// Represents a push style state update sequence.
protocol ObservableType {
    associatedtype Element
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element
}

extension ObservableType {
    func subscribe(_ actionHandler: @escaping (Action) -> Void) -> Disposable {
        let observer = AnyObserver(actionHandler: actionHandler)
        return self.asObservable().subscribe(observer)
    }
}

extension ObservableType {
    func asObservable() -> Observable<Element> {
        return Observable.create { observer in
            return self.subscribe(observer)
        }
    }
}

/// Type-erased `ObervableType`.
///
/// You can only get `Observable` instances through the `create` static factory, as used by the `Store`.
open class Observable<Element>: ObservableType {
    internal init() {
        // no-op
    }

    public func subscribe<Observer>(_ observer: Observer) -> Disposable {
        fatalError("Method not implemented: \(#function)")
    }

    /// Optimization hook for multiple `select` calls in succession. Is overwritten by the `Select` type.
    internal func composeMap<Substate>(_ transform: @escaping (Element) -> Substate) -> Observable<Substate> {
        return ReSwift.select(source: self, transform: transform)
    }

    public func asObservable() -> Observable<Element> {
        return self
    }
}
