//
//  StoreType.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/28/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

/**
 Defines the interface of Stores in ReSwift. `Store` is the default implementation of this
 interface. Applications have a single store that stores the entire application state.
 Stores receive actions and use reducers combined with these actions, to calculate state changes.
 Upon every state update a store informs all of its subscribers.
 */
public protocol StoreType: DispatchingStoreType {

    associatedtype State: StateType

    /// Initializes the store with a reducer, an initial state and a list of middleware.
    /// Middleware is applied in the order in which it is passed into this constructor.
    init(reducer: @escaping Reducer<State>, state: State?, middleware: [Middleware<State>])

    /// The current state stored in the store.
    var state: State! { get }

    /**
     The main dispatch function that is used by all convenience `dispatch` methods.
     This dispatch function can be extended by providing middlewares.
     */
    var dispatchFunction: DispatchFunction! { get }

    /**
     Subscribes the provided subscriber to this store.
     Subscribers will receive a call to `newState` whenever the
     state in this store changes.

     - parameter subscriber: Subscriber that will receive store updates
     */
    func subscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreSubscriberStateType == State

    /**
     Subscribes the provided subscriber to this store.
     Subscribers will receive a call to `newState` whenever the
     state in this store changes and the subscription decides to forward
     state update.

     - parameter subscriber: Subscriber that will receive store updates
     - parameter transform: A closure that receives a simple subscription and can return a
       transformed subscription. Subscriptions can be transformed to only select a subset of the
       state, or to skip certain state updates.
     */
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

    /**
     Unsubscribes the provided subscriber. The subscriber will no longer
     receive state updates from this store.

     - parameter subscriber: Subscriber that will be unsubscribed
     */
    func unsubscribe(_ subscriber: AnyStoreSubscriber)
}
