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

    private var _initialState: State?
    private let automaticallySkipsEquatable: Bool
    weak var subscriber: AnyStoreSubscriber?

    private(set) lazy var notify: (State, State) -> Void = { [unowned self] oldState, newState in
        self.subscriber?._newState(
            oldState: oldState,
            state: newState,
            automaticallySkipsEquatable: self.automaticallySkipsEquatable
        )
    }

    init(initialState: State, automaticallySkipsEquatable: Bool) {
        _initialState = initialState
        self.automaticallySkipsEquatable = automaticallySkipsEquatable
    }

    private func initialState() -> State {
        guard let initialState = _initialState else {
            // swiftlint:disable:next line_length
            fatalError("Subscription requires initial state, this subscription may not have been created from a store, or it has been transformed, and cannot be subscribed to. (Subscribe to the transformed subscription instead.)")
        }

        // We've now used the initial state to notify, or to pass on to a transformed subscription
        // So now we nil it out to preserve memory. Accessing this again is a programming error.
        _initialState = nil

        return initialState
    }

    public func select<SelectedState>(_ selector: @escaping (State) -> SelectedState) -> Subscription<SelectedState> {
        let subscription = Subscription<SelectedState>(
            initialState: selector(self.initialState()),
            automaticallySkipsEquatable: automaticallySkipsEquatable
        )
        notify = { oldState, newState in
            let newSelected = selector(newState)
            let oldSelected = selector(oldState)
            subscription.notify(oldSelected, newSelected)
        }
        return subscription
    }

    public func skip(when skip: @escaping (_ oldState: State, _ newState: State) -> Bool) -> Subscription<State> {
        let subscription = Subscription<State>(
            initialState: self.initialState(),
            automaticallySkipsEquatable: false // Since we're declaring a skip manually, we can avoid double-skips
        )
        notify = { oldState, newState in
            if !skip(oldState, newState) {
                subscription.notify(oldState, newState)
            }
        }
        return subscription
    }

    public func only(when only: @escaping (_ oldState: State, _ newState: State) -> Bool) -> Subscription<State> {
        let subscription = Subscription<State>(
            initialState: self.initialState(),
            automaticallySkipsEquatable: false // Since we're declaring a skip manually, we can avoid double-skips
        )
        notify = { oldState, newState in
            if only(oldState, newState) {
                subscription.notify(oldState, newState)
            }
        }
        return subscription
    }

    public func subscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreSubscriberStateType == State {
        assert(self.subscriber == nil, "Subscriptions do not support multiple subscribers")
        self.subscriber = subscriber
        subscriber._initialState(state: initialState())
        _initialState = nil
    }
}
