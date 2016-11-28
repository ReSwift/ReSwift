//
//  ObservableStoreType.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 11/17/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

/**
 Defines the interface of Stores in ReSwift. `Store` is the default implementation of this
 interface. Applications have a single store that stores the entire application state.
 Stores receive actions and use reducers combined with these actions, to calculate state changes.
 Upon every state update a store informs all of its subscribers.
 */
public protocol ObservableStoreType {

    associatedtype ObservableProperty: ObservablePropertyType
    associatedtype State: StateType

    /// Initializes the store with a reducer and an intial state.
    init(reducer: AnyReducer, stateType: State.Type, observable: ObservableProperty)

    /// Initializes the store with a reducer, an initial state and a list of middleware.
    /// Middleware is applied in the order in which it is passed into this constructor.
    init(reducer: AnyReducer,
         stateType: State.Type,
         observable: ObservableProperty,
         middleware: [Middleware])

    /// The observable of values stored in the store.
    var observable: ObservableProperty! { get }

    /**
     The main dispatch function that is used by all convenience `dispatch` methods.
     This dispatch function can be extended by providing middlewares.
     */
    var dispatchFunction: DispatchFunction! { get }

    /**
     Dispatches an action. This is the simplest way to modify the stores state.

     Example of dispatching an action:

     ```
     store.dispatch( CounterAction.IncreaseCounter )
     ```

     - parameter action: The action that is being dispatched to the store
     - returns: By default returns the dispatched action, but middlewares can change the
     return type, e.g. to return promises
     */
    func dispatch(_ action: Action) -> Any
}
