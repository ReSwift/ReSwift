//
//  IncompleteSubscription.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-04.
//  Copyright © 2019 ReSwift. All rights reserved.
//

class BlockSubscription<Substate>: StoreSubscriber {
    let callback: (Substate) -> Void

    init(callback: @escaping (Substate) -> Void) {
        self.callback = callback
    }

    func newState(state: Substate) {
        self.callback(state)
    }
}

extension Store {
    func asObservable() -> Observable<State> {
        return Observable.create { [weak self] observer -> Disposable in
            let subscription = BlockSubscription(callback: { (state: State) in
                observer.on(state)
            })

            self?.subscribe(subscription)

            return createDisposable {
                self?.unsubscribe(subscription)
            }
        }
    }
}

public final class IncompleteSubscription<RootStoreState: StateType, Substate> {
    typealias CompatibleStore = Store<RootStoreState>

    internal let store: CompatibleStore
    internal let observable: Observable<Substate>

    /// Used during transformations.
    internal init(store: CompatibleStore, observable: Observable<Substate>) {
        self.store = store
        self.observable = observable
    }

    public func subscribe<Subscriber: StoreSubscriber>(_ subscriber: Subscriber) where Subscriber.StoreSubscriberStateType == Substate {
        let bridge = Bridge<RootStoreState, Substate>(subscriber: subscriber)
        self.store.subscribe(bridge)
    }
}

extension IncompleteSubscription {
    public func select<SelectedSubstate>(_ transform: @escaping (Substate) -> SelectedSubstate) -> IncompleteSubscription<RootStoreState, SelectedSubstate> {
        return IncompleteSubscription<RootStoreState, SelectedSubstate>(
            store: self.store,
            observable: self.observable.select(transform))
    }

    public func filter(_ predicate: @escaping (Substate) -> Bool) -> IncompleteSubscription<RootStoreState, Substate> {
        return IncompleteSubscription<RootStoreState, Substate>(
            store: self.store,
            observable: self.observable.filter(predicate))
    }
}

private final class Bridge<RootStoreState: StateType, Substate>: StoreSubscriber {
    private let base: AnyStoreSubscriber

    init<Subscriber: StoreSubscriber>(subscriber: Subscriber) where Subscriber.StoreSubscriberStateType == Substate {
        self.base = subscriber
    }

    func newState(state: RootStoreState) {
        self.base._newState(state: state)
    }
}
