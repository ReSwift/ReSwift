//
//  Select.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

extension IncompleteSubscription {
    public func select<SelectedSubstate>(
        _ transform: @escaping (Substate) -> SelectedSubstate
        ) -> IncompleteSubscription<RootStoreState, SelectedSubstate>
    {
        return IncompleteSubscription<RootStoreState, SelectedSubstate>(
            store: self.store,
            observable: self.observable.select(transform))
    }
}

extension ObservableType {
    func select<SelectSubstate>(_ transform: @escaping (Substate) -> SelectSubstate) -> Observable<SelectSubstate> {
        return self.asObservable().composeSelect(transform)
    }
}

internal func select<FromState, ToState>(
    source: Observable<FromState>,
    transform: @escaping (FromState) -> ToState
    ) -> Observable<ToState>
{
    return Select(source: source, transform: transform)
}

final private class Select<FromState, ToState>: Producer<ToState> {
    typealias Source = Observable<FromState>
    typealias Transform = (FromState) -> ToState

    private let source: Source
    private let transform: Transform

    init(source: Source, transform: @escaping Transform) {
        self.source = source
        self.transform = transform
    }

    override func composeSelect<Substate>(_ outerTransform: @escaping (ToState) -> Substate) -> Observable<Substate> {
        let innerTransform = self.transform
        return Select<FromState, Substate>(source: self.source) { (original: FromState) -> Substate in
            return outerTransform(innerTransform(original))
        }
    }

    override func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
        ) -> (sink: Disposable, subscription: Disposable)
        where Observer.Substate == ToState
    {
        let sink = SelectSink(transform: self.transform, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink, subscription)
    }
}

final private class SelectSink<FromState, Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = FromState
    typealias ToState = Observer.Substate
    typealias Transform = (FromState) -> ToState

    private let transform: Transform

    init(transform: @escaping Transform, observer: Observer, cancel: Cancelable) {
        self.transform = transform
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ state: FromState) {
        self.forward(state: self.transform(state))
    }
}
