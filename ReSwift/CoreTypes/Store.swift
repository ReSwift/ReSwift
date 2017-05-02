//
//  Store.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

/**
 This class is the default implementation of the `Store` protocol. You will use this store in most
 of your applications. You shouldn't need to implement your own store.
 You initialize the store with a reducer and an initial application state. If your app has multiple
 reducers you can combine them by initializng a `MainReducer` with all of your reducers as an
 argument.
 */
open class Store<State: StateType>: StoreType {

    typealias SubscriptionType = SubscriptionBox<State>

    // swiftlint:disable todo
    // TODO: Setter should not be public; need way for store enhancers to modify appState anyway
    // swiftlint:enable todo

    /*private (set)*/ public var state: State! {
        didSet {
            subscriptions = subscriptions.filter { $0.subscriber != nil }
            subscriptions.forEach {
                $0.newValues(oldState: oldValue, newState: state)
            }
        }
    }

    public var dispatchFunction: DispatchFunction!

    private var reducer: Reducer<State>

    var subscriptions: [SubscriptionType] = []

    private var isDispatching = false

    public required init(
        reducer: @escaping Reducer<State>,
        state: State?,
        middleware: [Middleware<State>] = []
    ) {
        self.reducer = reducer

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware
            .reversed()
            .reduce({ [unowned self] params in
                return self._defaultDispatch(params: params)
            }) { [unowned self] dispatchFunction, middleware in
                // If the store get's deinitialized before the middleware is complete; drop
                // the action without dispatching.
                let getState = { [weak self] in self?.state }
                return middleware(self, getState)(dispatchFunction)
        }

        if let state = state {
            self.state = state
        } else {
            dispatch(ReSwiftInit())
        }
    }

    open func subscribe<S: StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
            _ = subscribe(subscriber, transform: nil)
    }

    open func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    {
        // If the same subscriber is already registered with the store, replace the existing
        // subscription with the new one.
        if let index = subscriptions.index(where: { $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }

        // Create a subscription for the new subscriber.
        let originalSubscription = Subscription<State>()
        // Call the optional transformation closure. This allows callers to modify
        // the subscription, e.g. in order to subselect parts of the store's state.
        let transformedSubscription = transform?(originalSubscription)

        let subscriptionBox = SubscriptionBox(
            originalSubscription: originalSubscription,
            transformedSubscription: transformedSubscription,
            subscriber: subscriber
        )

        subscriptions.append(subscriptionBox)

        if let state = self.state {
            originalSubscription.newValues(oldState: nil, newState: state)
        }
    }

    open func unsubscribe(_ subscriber: AnyStoreSubscriber) {
        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
    }

    // swiftlint:disable:next identifier_name
    open func _defaultDispatch(params: [Any]) -> Any {
        guard !isDispatching else {
            raiseFatalError(
                "ReSwift:ConcurrentMutationError- Action has been dispatched while" +
                " a previous action is action is being processed. A reducer" +
                " is dispatching an action, or ReSwift is used in a concurrent context" +
                " (e.g. from multiple threads)."
            )
        }

        guard let action = params.first as? Action else {
            raiseFatalError(
                "ReSwift:NonActionReachedDefaultDispatch - Dispatch param is not an action"
            )
        }

        isDispatching = true
        let newState = reducer(action, state)
        isDispatching = false

        state = newState

        return action
    }

    @discardableResult
    open func dispatch(_ params: Any...) -> Any {
        return dispatchFunction(params)
    }
}

// MARK: Skip Repeats for Equatable States

extension Store where State: Equatable {
    open func subscribe<S: StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
            _ = subscribe(subscriber, transform: { $0.skipRepeats() })
    }
}
