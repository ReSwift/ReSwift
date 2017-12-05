//
//  Subscription.swift
//  ReSwift
//
//  Created by Virgilio Favero Neto on 4/02/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

/// Represents a subscription of a subscriber to the store. The subscription determines which new
/// values from the store are forwarded to the subscriber, and how they are transformed.
/// The subscription acts as a very-light weight signal/observable that you might know from
/// reactive programming libraries.
public class Subscription<State> {

    private var getState: () -> State?
    private let automaticallySkipsEquatable: Bool
    var subscribers: [WeakSubscriberBox] = []

    private(set) var notify: ((State, State) -> Void)?

    init(getState: @escaping () -> State?, automaticallySkipsEquatable: Bool) {
        self.getState = getState
        self.automaticallySkipsEquatable = automaticallySkipsEquatable
    }

    private(set) lazy var originalNotify: (State, State) -> Void = { [unowned self] oldState, newState in
        self.subscribers.forEach {
            $0.subscriber?._newState(
                oldState: oldState,
                state: newState,
                automaticallySkipsEquatable: self.automaticallySkipsEquatable
            )
        }
    }

    public func select<SelectedState>(_ selector: @escaping (State) -> SelectedState) -> Subscription<SelectedState> {
        let getState = self.getState // copy the closure so we're not referencing self
        let subscription = Subscription<SelectedState>(
            getState: { getState().map(selector) },
            automaticallySkipsEquatable: automaticallySkipsEquatable
        )
        let previousNotify = notify // Capture the existing notify function to allow splitting
        notify = { oldState, newState in
            previousNotify?(oldState, newState) // Split the chain if necessary

            let newSelected = selector(newState)
            let oldSelected = selector(oldState)
            let notify = subscription.notify ?? subscription.originalNotify
            notify(oldSelected, newSelected)
        }
        return subscription
    }

    public func skip(when skip: @escaping (_ oldState: State, _ newState: State) -> Bool) -> Subscription<State> {
        let subscription = Subscription<State>(
            getState: self.getState,
            automaticallySkipsEquatable: false // Since we're declaring a skip manually, we can avoid double-skips
        )
        let previousNotify = notify // Capture the existing notify function to allow splitting
        notify = { oldState, newState in
            previousNotify?(oldState, newState) // Split the chain if necessary

            if !skip(oldState, newState) {
                let notify = subscription.notify ?? subscription.originalNotify
                notify(oldState, newState)
            }
        }
        return subscription
    }

    public func only(when only: @escaping (_ oldState: State, _ newState: State) -> Bool) -> Subscription<State> {
        let subscription = Subscription<State>(
            getState: self.getState,
            automaticallySkipsEquatable: false // Since we're declaring a skip manually, we can avoid double-skips
        )
        let previousNotify = notify // Capture the existing notify function to allow splitting
        notify = { oldState, newState in
            previousNotify?(oldState, newState) // Split the chain if necessary

            if only(oldState, newState) {
                let notify = subscription.notify ?? subscription.originalNotify
                notify(oldState, newState)
            }
        }
        return subscription
    }

    public func subscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreSubscriberStateType == State {
        self.subscribers.append(WeakSubscriberBox(subscriber: subscriber))
        subscriber._initialState(state: self.getState() as Any)
    }
}

struct WeakSubscriberBox {
    weak var subscriber: AnyStoreSubscriber?
}
