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

extension Store {
    func asObservable() -> Observable<State> {
        return Observable.create { [weak self] observer -> Disposable in
            let subscription = BlockSubscriber { (state: State) in
                observer.on(state)
            }

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
