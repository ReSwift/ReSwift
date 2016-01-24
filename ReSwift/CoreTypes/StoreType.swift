//
//  Store.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 11/28/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

/**
 Defines the interface of Stores in Swift Flow. `MainStore` is the default implementation of this
 interaface. Applications have a single store that stores the entire application state.
 Stores receive actions and use reducers combined with these actions, to calculate state changes.
 Upon every state update a store informs all of its subscribers.
 */
public protocol StoreType {

    typealias State: StateType

    /// Initializes the store with a reducer and an intial state.
    init(reducer: AnyReducer, state: State?)

    /// Initializes the store with a reducer, an initial state and a list of middleware.
    /// Middleware is applied in the order in which it is passed into this constructor.
    init(reducer: AnyReducer, state: State?, middleware: [Middleware])

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
    func subscribe<S: StoreSubscriber where S.StoreSubscriberStateType == State>(subscriber: S)

    /**
     Unsubscribes the provided subscriber. The subscriber will no longer
     receive state updates from this store.

     - parameter subscriber: Subscriber that will be unsubscribed
     */
    func unsubscribe(subscriber: AnyStoreSubscriber)

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
    func dispatch(action: Action) -> Any

    /**
     Dispatches an action creator to the store. Action creators are functions that generate
     actions. They are called by the store and receive the current state of the application
     and a reference to the store as their input.

     Based on that input the action creator can either return an action or not. Alternatively
     the action creator can also perform an asynchronous operation and dispatch a new action
     at the end of it.

     Example of an action creator:

     ```
     func deleteNote(noteID: Int) -> ActionCreator {
     return { state, store in
     // only delete note if editing is enabled
     if (state.editingEnabled == true) {
     return NoteDataAction.DeleteNote(noteID)
     } else {
     return nil
     }
     }
     }
     ```

     This action creator can then be dispatched as following:

     ```
     store.dispatch( noteActionCreatore.deleteNote(3) )
     ```

     - returns: By default returns the dispatched action, but middlewares can change the
     return type, e.g. to return promises
     */
    func dispatch(actionCreator: ActionCreator) -> Any

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously.
     */
    func dispatch(asyncActionCreator: AsyncActionCreator)

    /**
     Dispatches an action and calls the callback as soon as the action has been processed.
     You will receive the updated store state as part of this callback.

     Example of dispatching an action and implementing a callback:

     ```
     store.dispatch( CounterAction.IncreaseCounter ) { state in
     print("New state: \(state)")
     }
     ```

     - parameter action: The action that is being dispatched to the store
     - returns: By default returns the dispatched action, but middlewares can change the
     return type, e.g. to return promises
     */
    func dispatch(action: Action, callback: DispatchCallback?) -> Any

    /**
     Dispatches an action creator to the store. Action creators are functions that generate
     actions. They are called by the store and receive the current state of the application
     and a reference to the store as their input.

     Based on that input the action creator can either return an action or not. Alternatively
     the action creator can also perform an asynchronous operation and dispatch a new action
     at the end of it.

     Example of an action creator:

     ```
     func deleteNote(noteID: Int) -> ActionCreator {
     return { state, store in
     // only delete note if editing is enabled
     if (state.editingEnabled == true) {
     return NoteDataAction.DeleteNote(noteID)
     } else {
     return nil
     }
     }
     }
     ```

     This action creator can then be dispatched as following:

     ```
     store.dispatch( noteActionCreatore.deleteNote(3) )
     ```

     This overloaded version of `dispatch` will call the provided `callback` as soon as a new
     state has been calculated based on the dispatch action.

     - Note: If the ActionCreator does not dispatch an action, the callback block will never
     be called

     - returns: By default returns the dispatched action, but middlewares can change the
     return type, e.g. to return promises
     */
    func dispatch(actionCreator: ActionCreator, callback: DispatchCallback?) -> Any

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously. Use this method if you want to wait for the state change
     triggered by the asynchronously generated action creator.

     This overloaded version of `dispatch` calls the provided `callback` as soon as the
     asynchronoously dispatched action has caused a new state calculation.

     - Note: If the ActionCreator does not dispatch an action, the callback block will never
     be called
     */
    func dispatch(asyncActionCreator: AsyncActionCreator, callback: DispatchCallback?)


    /**
     An optional callback that can be passed to the `dispatch` method.
     This callback will be called when the dispatched action triggers a new state calculation.
     This is useful when you need to wait on a state change, triggered by an action (e.g. wait on
     a successful login). However, you should try to use this callback very seldom as it
     deviates slighlty from the unidirectional data flow principal.
     */
    typealias DispatchCallback = (State) -> Void

    /**
     An ActionCreator is a function that, based on the received state argument, might or might not
     create an action.

     Example:

     ```
     func deleteNote(noteID: Int) -> ActionCreator {
     return { state, store in
     // only delete note if editing is enabled
     if (state.editingEnabled == true) {
     return NoteDataAction.DeleteNote(noteID)
     } else {
     return nil
     }
     }
     }
     ```

     */
    typealias ActionCreator = (state: State, store: StoreType) -> Action?

    /// AsyncActionCreators allow the developer to wait for the completion of an async action.
    typealias AsyncActionCreator = (state: State, store: StoreType,
    actionCreatorCallback: ActionCreator -> Void) -> Void
}
