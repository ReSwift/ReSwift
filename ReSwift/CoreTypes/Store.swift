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

    // swiftlint:disable todo
    // TODO: Setter should not be public; need way for store enhancers to modify appState anyway

    /*private (set)*/ public var state: State! {
        didSet {
            subscriptions = subscriptions.filter { $0.subscriber != nil }
            subscriptions.forEach {
                // if a selector is available, subselect the relevant state
                // otherwise pass the entire state to the subscriber
                #if swift(>=3)
                    $0.subscriber?._newState(state: $0.selector?(state) ?? state)
                #else
                    $0.subscriber?._newState($0.selector?(state) ?? state)
                #endif
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
            .reduce({ [unowned self] action in
                #if swift(>=3)
                    return self._defaultDispatch(action: action)
                #else
                    return self._defaultDispatch(action)
                #endif
            }) {
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

    private func _isNewSubscriber(subscriber: AnyStoreSubscriber) -> Bool {
        if subscriptions.contains(where: { $0.subscriber === subscriber }) {
            print("Store subscriber is already added, ignoring.")
            return false
        }

        return true
    }

    #if swift(>=3)
    public func subscribe<S: StoreSubscriber
        where S.StoreSubscriberStateType == State>(_ subscriber: S) {
            subscribe(subscriber, selector: nil)
    }
    #else
    public func subscribe<S: StoreSubscriber
        where S.StoreSubscriberStateType == State>(subscriber: S) {
            subscribe(subscriber, selector: nil)
    }
    #endif

    #if swift(>=3)
    public func subscribe<SelectedState, S: StoreSubscriber
        where S.StoreSubscriberStateType == SelectedState>
        (_ subscriber: S, selector: ((State) -> SelectedState)?) {
            if !_isNewSubscriber(subscriber: subscriber) { return }

            subscriptions.append(Subscription(subscriber: subscriber, selector: selector))

            if let state = self.state {
                subscriber._newState(state: selector?(state) ?? state)
            }
    }
    #else
    public func subscribe<SelectedState, S: StoreSubscriber
        where S.StoreSubscriberStateType == SelectedState>
        (subscriber: S, selector: ((State) -> SelectedState)?) {
            if !_isNewSubscriber(subscriber) { return }

            subscriptions.append(Subscription(subscriber: subscriber, selector: selector))

            if let state = self.state {
                subscriber._newState(selector?(state) ?? state)
            }
    }
    #endif

    #if swift(>=3)
    public func unsubscribe(_ subscriber: AnyStoreSubscriber) {
        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
    }
    #else
    public func unsubscribe(subscriber: AnyStoreSubscriber) {
        if let index = subscriptions.indexOf({ return $0.subscriber === subscriber }) {
            subscriptions.removeAtIndex(index)
        }
    }
    #endif

    public func _defaultDispatch(action: Action) -> Any {
        guard !isDispatching else {
            raiseFatalError(
                "ReSwift:IllegalDispatchFromReducer - Reducers may not dispatch actions.")
        }

        isDispatching = true
        #if swift(>=3)
            let newState = reducer._handleAction(action: action, state: state) as! State
        #else
            let newState = reducer._handleAction(action, state: state) as! State
        #endif
        isDispatching = false

        state = newState

        return action
    }

    #if swift(>=3)
    @discardableResult
    public func dispatch(_ action: Action) -> Any {
        let returnValue = dispatchFunction(action)

        return returnValue
    }
    #else
    public func dispatch(action: Action) -> Any {
        let returnValue = dispatchFunction(action)

        return returnValue
    }
    #endif

    #if swift(>=3)
    @discardableResult
    public func dispatch(_ actionCreatorProvider: ActionCreator) -> Any {
        let action = actionCreatorProvider(state: state, store: self)

        if let action = action {
            dispatch(action)
        }

        return action
    }
    #else
    public func dispatch(actionCreatorProvider: ActionCreator) -> Any {
        let action = actionCreatorProvider(state: state, store: self)

        if let action = action {
            dispatch(action)
        }

        return action
    }
    #endif

    #if swift(>=3)
    public func dispatch(_ asyncActionCreatorProvider: AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }
    #else
    public func dispatch(asyncActionCreatorProvider: AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }
    #endif

    #if swift(>=3)
    public func dispatch(_ actionCreatorProvider: AsyncActionCreator,
                         callback: DispatchCallback?) {
        actionCreatorProvider(state: state, store: self) { actionProvider in
            let action = actionProvider(state: self.state, store: self)

            if let action = action {
                self.dispatch(action)
                callback?(self.state)
            }
        }
    }
    #else
    public func dispatch(actionCreatorProvider: AsyncActionCreator, callback: DispatchCallback?) {
        actionCreatorProvider(state: state, store: self) { actionProvider in
            let action = actionProvider(state: self.state, store: self)

            if let action = action {
                self.dispatch(action)
                callback?(self.state)
            }
        }
    }
    #endif

    public typealias DispatchCallback = (State) -> Void

    public typealias ActionCreator = (state: State, store: Store) -> Action?

    public typealias AsyncActionCreator = (
        state: State,
        store: Store,
        actionCreatorCallback: (ActionCreator) -> Void
    ) -> Void
}
