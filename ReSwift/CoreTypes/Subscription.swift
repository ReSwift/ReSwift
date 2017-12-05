//
//  Subscription.swift
//  ReSwift
//
//  Created by Virgilio Favero Neto on 4/02/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

/**
 Represents a pending subscription of a subscriber to the store. The subscription determines
 which new values from the store are forwarded to the subscriber, and how they are transformed.
 The subscription acts as a very-light weight signal/observable that you might know from
 reactive programming libraries.
 */
public class PendingSubscription<S: StoreType, State> {

    private weak var store: S?
    var originalSubscription: PendingSubscription<S, S.State>?
    private let automaticallySkipEquatable: Bool

    private lazy var notify: (State, State) -> (AnyStoreSubscriber) -> Void = { oldState, newState in
        return { subscriber in
            subscriber._newState(state: newState)
        }
    }

    init(store: S?, automaticallySkipEquatable: Bool) {
        self.store = store
        self.automaticallySkipEquatable = automaticallySkipEquatable
    }

    public func select<SelectedState>(_ selector: @escaping (State) -> SelectedState)
        -> PendingSubscription<S, SelectedState> {
            let subscription = PendingSubscription<S, SelectedState>(
                store: self.store,
                automaticallySkipEquatable: automaticallySkipEquatable
            )
            subscription.originalSubscription = self.originalSubscription ?? (self as! PendingSubscription<S, S.State>)
            notify = { oldState, newState in
                return { subscriber in
                    let newSelected = selector(newState)
                    let oldSelected = selector(oldState)
                    subscription.notify(oldSelected, newSelected)(subscriber)
                }

            }
            return subscription
    }

    public func skip(when skip: @escaping (_ oldState: State, _ newState: State) -> Bool)
        -> PendingSubscription<S, State> {
            let subscription = PendingSubscription<S, State>(
                store: self.store,
                automaticallySkipEquatable: false // Since we're declaring a skip manually, we can avoid double-skips
            )
            subscription.originalSubscription = self.originalSubscription ?? (self as! PendingSubscription<S, S.State>)
            notify = { oldState, newState in
                return { subscriber in
                    if !skip(oldState, newState) {
                        subscription.notify(oldState, newState)(subscriber)
                    }
                }
            }
            return subscription
    }

    public func only(when only: @escaping (_ oldState: State, _ newState: State) -> Bool)
        -> PendingSubscription<S, State> {
            let subscription = PendingSubscription<S, State>(
                store: self.store,
                automaticallySkipEquatable: false // Since we're declaring a skip manually, we can avoid double-skips
            )
            subscription.originalSubscription = self.originalSubscription ?? (self as! PendingSubscription<S, S.State>)
            notify = { oldState, newState in
                return { subscriber in
                    if only(oldState, newState) {
                        subscription.notify(oldState, newState)(subscriber)
                    }
                }
            }
            return subscription
    }

    // Subscribe with a transformed subscription
    public func subscribe<Subscriber: StoreSubscriber>(_ subscriber: Subscriber)
        where Subscriber.StoreSubscriberStateType == State {
            guard let originalSubscription = self.originalSubscription else {
                fatalError("Transformed subscription without an original subscription")
            }
            let subscription = Subscription<S.State>(
                subscriber: subscriber,
                notify: originalSubscription.notify
            )
            self.store?.addSubscription(subscription)
    }

    // Subscribe with the original subscription
    public func subscribe<Subscriber: StoreSubscriber>(_ subscriber: Subscriber)
        where Subscriber.StoreSubscriberStateType == S.State, State == S.State {
            let subscription = Subscription<S.State>(
                subscriber: subscriber,
                notify: self.notify
            )
            self.store?.addSubscription(subscription)
    }
}

open class Subscription<State> {
    private(set) weak var subscriber: AnyStoreSubscriber?
    private(set) var notify: (State, State) -> (AnyStoreSubscriber) -> Void

    init(
        subscriber: AnyStoreSubscriber,
        notify: @escaping (State, State) -> (AnyStoreSubscriber) -> Void
        ) {
        self.subscriber = subscriber
        self.notify = notify
    }
}
