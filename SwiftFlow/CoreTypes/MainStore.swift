//
//  MainStore.swift
//  SwiftFlow
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
public class MainStore<State: StateType>: Store {

    public var state: State {
        didSet {
            subscribers.forEach { $0._newState(state) }
        }
    }

    public var dispatchFunction: DispatchFunction!

    private var reducer: AnyReducer
    var subscribers: [AnyStoreSubscriber] = []
    private var isDispatching = false

    public required convenience init(reducer: AnyReducer, state: State) {
        self.init(reducer: reducer, state: state, middleware: [])
    }

    public required init(reducer: AnyReducer, state: State, middleware: [Middleware]) {
        self.reducer = reducer
        self.state = state

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware.reverse().reduce(_defaultDispatch) {
            function, middleware in
                return middleware(self.dispatch, { self.state })(function)
        }
    }

    public func subscribe(subscriber: AnyStoreSubscriber) {
        if subscribers.contains({ $0 === subscriber }) {
            print("Store subscriber is already added, ignoring.")
            return
        }

        subscribers.append(subscriber)
        subscriber._newState(state)
    }

    public func unsubscribe(subscriber: AnyStoreSubscriber) {
        if let index = subscribers.indexOf({ return $0 === subscriber }) {
            subscribers.removeAtIndex(index)
        }
    }

    public func _defaultDispatch(action: Action) -> Any {
        if isDispatching {
            // Use Obj-C exception since throwing of exceptions can be verified through tests
            NSException.raise("SwiftFlow:IllegalDispatchFromReducer", format: "Reducers may not " +
                "dispatch actions.", arguments: getVaList(["nil"]))
        }

        isDispatching = true
        let newState = reducer._handleAction(action, state: state)
        isDispatching = false

        state = newState as! State
        return action
    }

    public func dispatch(action: Action) -> Any {
        return dispatch(action, callback: nil)
    }

    public func dispatch(actionCreatorProvider: ActionCreator) -> Any {
        return dispatch(actionCreatorProvider, callback: nil)
    }

    public func dispatch(asyncActionCreatorProvider: AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    public func dispatch(action: Action, callback: DispatchCallback?) -> Any {
        let returnValue = dispatchFunction(action)
        callback?(state)

        return returnValue
    }

    public func dispatch(actionCreatorProvider: ActionCreator, callback: DispatchCallback?) -> Any {
        let action = actionCreatorProvider(state: state, store: self)
        _ = action.map { dispatch($0, callback: callback) }

        return action
    }

    public func dispatch(actionCreatorProvider: AsyncActionCreator, callback: DispatchCallback?) {
        actionCreatorProvider(state: state, store: self) { actionProvider in
            let action = actionProvider(state: self.state, store: self)
            _ = action.map { self.dispatch($0, callback: callback) }
        }
    }
}
