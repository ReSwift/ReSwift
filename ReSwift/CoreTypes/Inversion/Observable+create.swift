//
//  Observable+create.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

extension Observable {
    /// Starting point of events, aka state updates.
    internal static func create(_ subscribe: @escaping (AnyObserver<Substate>) -> Disposable) -> Observable<Substate> {
        return AnonymousObservable(subscribe)
    }
}

final private class AnonymousObservable<Substate>: Producer<Substate> {
    typealias Handler = (AnyObserver<Substate>) -> Disposable

    let handler: Handler

    init(_ handler: @escaping Handler) {
        self.handler = handler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Substate == Substate {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink, subscription)
    }
}

final private class AnonymousObservableSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Substate = Observer.Substate
    typealias Parent = AnonymousObservable<Substate>

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ state: Substate) {
        self.observer.on(state)
    }

    func run(_ parent: Parent) -> Disposable {
        return parent.handler(AnyObserver(self))
    }
}
