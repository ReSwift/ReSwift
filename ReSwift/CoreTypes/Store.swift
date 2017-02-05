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
        middleware: [Middleware] = []
    ) {
        self.reducer = reducer

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware
            .reversed()
            .reduce({ [unowned self] action in
                return self._defaultDispatch(action: action)
            }) { [weak self] dispatchFunction, middleware in
                let getState = { self?.state }
                return middleware(self?.dispatch, getState)(dispatchFunction)
        }

        if let state = state {
            self.state = state
        } else {
            dispatch(ReSwiftInit())
        }
    }

    private func _isNewSubscriber(subscriber: AnyStoreSubscriber) -> Bool {
        let contains = subscriptions.contains(where: { $0.subscriber === subscriber })

        if contains {
            print("Store subscriber is already added, ignoring.")
            return false
        }

        return true
    }

    open func subscribe<S: StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
            _ = subscribe(subscriber, transform: nil)
    }

    @discardableResult
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

    open func _defaultDispatch(action: Action) {
        guard !isDispatching else {
            raiseFatalError(
                "ReSwift:IllegalDispatchFromReducer - Reducers may not dispatch actions.")
        }

        isDispatching = true
        let newState = reducer(action, state)
        isDispatching = false

        state = newState
    }

    open func dispatch(_ action: Action) {
        dispatchFunction(action)
    }

    open func dispatch(_ actionCreatorProvider: @escaping ActionCreator) {
        if let action = actionCreatorProvider(state, self) {
            dispatch(action)
        }
    }

    open func dispatch(_ asyncActionCreatorProvider: @escaping AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    open func dispatch(_ actionCreatorProvider: @escaping AsyncActionCreator,
                       callback: DispatchCallback?) {
        actionCreatorProvider(state, self) { actionProvider in
            let action = actionProvider(self.state, self)

            if let action = action {
                self.dispatch(action)
                callback?(self.state)
            }
        }
    }

    public typealias DispatchCallback = (State) -> Void

    public typealias ActionCreator = (_ state: State, _ store: Store) -> Action?

    public typealias AsyncActionCreator = (
        _ state: State,
        _ store: Store,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
    ) -> Void
}
