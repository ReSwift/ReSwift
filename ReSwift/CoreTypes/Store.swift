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
public class Store<State: StateType>: StoreType {

    typealias SubscriptionType = Subscription<State>

    // TODO: Setter should not be public; need way for store enhancers to modify appState anyway

    /*private (set)*/ public var state: State! {
        didSet {
            subscriptions = subscriptions.filter { $0.subscriber != nil }
            subscriptions.forEach {
                // if a selector is available, subselect the relevant state
                // otherwise pass the entire state to the subscriber
                $0.subscriber?._newState($0.selector?(state) ?? state)
            }
        }
    }

    public var dispatchFunction: DispatchFunction!

    private var reducer: AnyReducer

    var subscriptions: [SubscriptionType] = []

    private var isDispatching = false

    public required convenience init(reducer: AnyReducer, state: State?) {
        self.init(reducer: reducer, state: state, middleware: [])
    }

    public required init(reducer: AnyReducer, state: State?, middleware: [Middleware]) {
        self.reducer = reducer

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware
            .reversed()
            .reduce({ [unowned self] action in self._defaultDispatch(action) }) {
                [weak self] dispatchFunction, middleware in
                    let getState = { self?.state }
                    return middleware(self?.dispatch, getState)(dispatchFunction)
        }

        if let state = state {
            self.state = state
        } else {
            dispatch(ReSwiftInit())
        }
    }

    private func _isNewSubscriber(_ subscriber: AnyStoreSubscriber) -> Bool {
        if subscriptions.contains({ $0.subscriber === subscriber }) {
            print("Store subscriber is already added, ignoring.")
            return false
        }

        return true
    }

    public func subscribe<S: StoreSubscriber
        where S.StoreSubscriberStateType == State>(_ subscriber: S) {
            subscribe(subscriber, selector: nil)
    }

    public func subscribe<SelectedState, S: StoreSubscriber
        where S.StoreSubscriberStateType == SelectedState>
        (_ subscriber: S, selector: ((State) -> SelectedState)?) {
            if !_isNewSubscriber(subscriber) { return }

            subscriptions.append(Subscription(subscriber: subscriber, selector: selector))

            if let state = self.state {
                let eitherState: Any = selector?(state) ?? state
                subscriber._newState(eitherState)
            }
    }

    public func unsubscribe(_ subscriber: AnyStoreSubscriber) {
        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
    }

    public func _defaultDispatch(_ action: Action) -> Any {
        if isDispatching {
            // Use Obj-C exception since throwing of exceptions can be verified through tests
            NSException.raise("SwiftFlow:IllegalDispatchFromReducer" as NSExceptionName,
                              format: "Reducers may not " +
                "dispatch actions.", arguments: getVaList(["nil"]))
        }

        isDispatching = true
        let newState = reducer._handleAction(action, state: state) as! State
        isDispatching = false

        state = newState

        return action
    }

    @discardableResult
    public func dispatch(_ action: Action) -> Any {
        let returnValue = dispatchFunction(action)

        return returnValue
    }

    public func dispatch(_ actionCreatorProvider: ActionCreator) -> Any {
        let action = actionCreatorProvider(state: state, store: self)

        if let action = action {
            dispatch(action)
        }

        return action
    }

    public func dispatch(_ asyncActionCreatorProvider: AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    public func dispatch(_ actionCreatorProvider: AsyncActionCreator, callback: DispatchCallback?) {
        actionCreatorProvider(state: state, store: self) { actionProvider in
            let action = actionProvider(state: self.state, store: self)

            if let action = action {
                self.dispatch(action)
                callback?(self.state)
            }
        }
    }

    public typealias DispatchCallback = (State) -> Void

    public typealias ActionCreator = (state: State, store: Store) -> Action?

    public typealias AsyncActionCreator = (
        state: State,
        store: Store,
        actionCreatorCallback: (ActionCreator) -> Void
    ) -> Void
}
