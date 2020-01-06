//
//  IncompleteSubscription.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-04.
//  Copyright © 2019 ReSwift. All rights reserved.
//

internal final class BlockSubscriber<S>: StoreSubscriber {
    typealias StoreSubscriberStateType = S
    private let block: (S) -> Void

    init(block: @escaping (S) -> Void) {
        self.block = block
    }

    func newState(state: S) {
        self.block(state)
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

    func asObservable() -> Observable<Substate> {
        return observable
    }
}

extension IncompleteSubscription {
    @discardableResult
    public func subscribe<Subscriber: StoreSubscriber>(_ subscriber: Subscriber)
        -> SubscriptionToken
        where Subscriber.StoreSubscriberStateType == Substate
    {
        return self.store.subscribe(subscription: self, subscriber: subscriber)
    }
}

extension IncompleteSubscription where Substate: Equatable {
    @discardableResult
    public func subscribe<Subscriber: StoreSubscriber>(_ subscriber: Subscriber)
        -> SubscriptionToken
        where Subscriber.StoreSubscriberStateType == Substate
    {
        return self.store.subscribe(subscription: self, subscriber: subscriber)
    }
}
