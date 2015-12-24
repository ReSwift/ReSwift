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
public class MainStore: Store {

    // TODO: Setter should not be public; need way for store enhancers to modify appState anyway

    /*private (set)*/ public var appState: StateType {
        didSet {
            subscribers.forEach { $0._newState(appState) }
        }
    }

    // FIXME: this is currently needed to satisfy initialization rules
    public var dispatch: DispatchFunction = { $0 }

    private var reducer: AnyReducer
    private var subscribers: [AnyStoreSubscriber] = []

    public required init(reducer: AnyReducer, appState: StateType) {
        self.reducer = reducer
        self.appState = appState
        self.dispatch = self._dispatch
    }

    public required init(reducer: AnyReducer, appState: StateType, middleware: [Middleware]) {
        self.reducer = reducer
        self.appState = appState
        self.dispatch = self._dispatch

        // Wrap the dispatch function with all middlewares
        self.dispatch = middleware.reverse().reduce(self.dispatch) { dispatchFunction, middleware in
            return middleware(self.dispatch, { self.appState })(dispatchFunction)
        }
    }

    public func subscribe(subscriber: AnyStoreSubscriber) {
        subscribers.append(subscriber)
        subscriber._newState(appState)
    }

    public func unsubscribe(subscriber: AnyStoreSubscriber) {
        let index = subscribers.indexOf { return $0 === subscriber }

        if let index = index {
            subscribers.removeAtIndex(index)
        }
    }

    public func _dispatch(action: ActionType) {
        self.appState = self.reducer._handleAction(self.appState, action: action.toAction())
    }

    public func dispatch(action: ActionConvertible) {
        dispatch(action.toAction())
    }

    public func dispatch(actionCreatorProvider: ActionCreator) {
        dispatch(actionCreatorProvider, callback: nil)
    }

    public func dispatch(asyncActionCreatorProvider: AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    public func dispatch(action: ActionType, callback: DispatchCallback?) {
        // Dispatch Asynchronously so that each subscriber receives the latest state
        // Without Async a receiver could immediately be called and emit a new state
        dispatch_async(dispatch_get_main_queue()) {
            self.dispatch(action)
            callback?(self.appState)
        }
    }

    public func dispatch(actionCreatorProvider: ActionCreator, callback: DispatchCallback?) {
        let action = actionCreatorProvider(state: self.appState, store: self)
        if let action = action {
            dispatch(action, callback: callback)
        }
    }

    public func dispatch(actionCreatorProvider: AsyncActionCreator, callback: DispatchCallback?) {
        actionCreatorProvider(state: self.appState, store: self) { actionProvider in
            let action = actionProvider(state: self.appState, store: self)
            if let action = action {
                self.dispatch(action, callback: callback)
            }
        }
    }

}
