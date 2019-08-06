//
//  Filter.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

extension IncompleteSubscription {
    public func filter(_ predicate: @escaping (Substate) -> Bool) -> IncompleteSubscription<RootStoreState, Substate> {
        return IncompleteSubscription<RootStoreState, Substate>(
            store: self.store,
            observable: self.observable.filter(predicate))
    }
}

extension ObservableType {
    func filter(_ predicate: @escaping (Substate) -> Bool) -> Observable<Substate> {
        return Filter(source: self.asObservable(), predicate: predicate)
    }
}

final private class Filter<Substate>: Producer<Substate> {
    typealias Predicate = (Substate) -> Bool

    private let source: Observable<Substate>
    private let predicate: Predicate

    init(source: Observable<Substate>, predicate: @escaping Predicate) {
        self.source = source
        self.predicate = predicate
    }

    override func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
        ) -> (sink: Disposable, subscription: Disposable)
        where Observer.Substate == Substate
    {
        let sink = FilterSink(predicate: self.predicate, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink, subscription)
    }
}

final private class FilterSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Substate = Observer.Substate
    typealias Predicate = (Substate) -> Bool

    private let predicate: Predicate

    init(predicate: @escaping Predicate, observer: Observer, cancel: Cancelable) {
        self.predicate = predicate
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ state: Substate) {
        guard self.predicate(state) else { return }
        self.forward(state: state)
    }
}
