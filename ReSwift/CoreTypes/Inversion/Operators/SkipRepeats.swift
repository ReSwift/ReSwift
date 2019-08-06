//
//  SkipRepeats.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-05.
//  Copyright © 2019 ReSwift. All rights reserved.
//

extension IncompleteSubscription where Substate: Equatable {
    public func skipRepeats() -> IncompleteSubscription<RootStoreState, Substate> {
        return IncompleteSubscription<RootStoreState, Substate>(
            store: self.store,
            observable: self.observable.skipRepeats())
    }
}

extension ObservableType where Substate: Equatable {
    func skipRepeats() -> Observable<Substate> {
        return self.skipRepeats({ $0 }, comparer: { ($0 == $1) })
    }
}

extension IncompleteSubscription {
    public func skipRepeats<Key: Equatable>(
        _ keySelector: @escaping (Substate) -> Key
        ) -> IncompleteSubscription<RootStoreState, Substate>
    {
        return self.skipRepeats(keySelector, comparer: { $0 == $1 })
    }

    public func skipRepeats(
        _ comparer: @escaping (Substate, Substate) -> Bool
        ) -> IncompleteSubscription<RootStoreState, Substate>
    {
        return self.skipRepeats({ $0 }, comparer: comparer)
    }

    public func skipRepeats<K>(
        _ keySelector: @escaping (Substate) -> K,
        comparer: @escaping (K, K) -> Bool
        ) -> IncompleteSubscription<RootStoreState, Substate>
    {
        return IncompleteSubscription<RootStoreState, Substate>(
            store: self.store,
            observable: self.observable.skipRepeats(keySelector, comparer: comparer))
    }
}

extension ObservableType {
    func skipRepeats<K>(_ keySelector: @escaping (Substate) -> K, comparer: @escaping (K, K) -> Bool)
        -> Observable<Substate> {
            return SkipRepeats(source: self.asObservable(), selector: keySelector, comparer: comparer)
    }
}

final private class SkipRepeats<Substate, Key>: Producer<Substate> {
    typealias KeySelector = (Substate) -> Key
    typealias EqualityComparer = (Key, Key) -> Bool

    private let source: Observable<Substate>
    fileprivate let selector: KeySelector
    fileprivate let comparer: EqualityComparer

    init(source: Observable<Substate>, selector: @escaping KeySelector, comparer: @escaping EqualityComparer) {
        self.source = source
        self.selector = selector
        self.comparer = comparer
    }

    override func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable)
        -> (sink: Disposable, subscription: Disposable)
        where Observer.Substate == Substate
    {
        let sink = SkipRepeatsSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}

final private class SkipRepeatsSink<Observer: ObserverType, Key>: Sink<Observer>, ObserverType {
    typealias Substate = Observer.Substate

    private let parent: SkipRepeats<Substate, Key>
    private var previousValue: Key?

    init(parent: SkipRepeats<Substate, Key>, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ state: Substate) {
        let currentValue = self.parent.selector(state)
        var areEqual = false

        if let previousValue = self.previousValue {
            areEqual = self.parent.comparer(previousValue, currentValue)
        }
        self.previousValue = currentValue

        guard !areEqual else { return }

        self.forward(state: state)
    }
}
