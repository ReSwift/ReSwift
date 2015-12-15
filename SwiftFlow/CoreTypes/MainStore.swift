//
//  MainStore.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

public class MainStore: Store {

    // TODO: Setter should not be public; need way for store enhancers to modify appState anyway
    /*private (set)*/ public var appState: StateType {
        didSet {
            subscribers.forEach { $0._newState(appState) }
        }
    }

    private var reducer: AnyReducer
    private var subscribers: [AnyStoreSubscriber] = []

    public init(reducer: AnyReducer, appState: StateType) {
        self.reducer = reducer
        self.appState = appState
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

    public func dispatch(action: ActionConvertible) {
        dispatch(action.toAction())
    }

    public func dispatch(action: ActionType) {
        dispatch(action.toAction(), callback: nil)
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
            self.appState = self.reducer._handleAction(self.appState, action: action.toAction())
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
