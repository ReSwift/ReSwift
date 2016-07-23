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
public protocol StoreType {

    associatedtype State: StateType

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
    #if swift(>=3)
    func subscribe<S: StoreSubscriber where S.StoreSubscriberStateType == State>(_ subscriber: S)
    #else
    func subscribe<S: StoreSubscriber where S.StoreSubscriberStateType == State>(subscriber: S)
    #endif

    /**
     Unsubscribes the provided subscriber. The subscriber will no longer
     receive state updates from this store.

     - parameter subscriber: Subscriber that will be unsubscribed
     */
    #if swift(>=3)
    func unsubscribe(_ subscriber: AnyStoreSubscriber)
    #else
    func unsubscribe(subscriber: AnyStoreSubscriber)
    #endif

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
    #if swift(>=3)
    func dispatch(_ action: Action) -> Any
    #else
    func dispatch(action: Action) -> Any
    #endif

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
    #if swift(>=3)
    func dispatch(_ actionCreator: ActionCreator) -> Any
    #else
    func dispatch(actionCreator: ActionCreator) -> Any
    #endif

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously.
     */
    #if swift(>=3)
    func dispatch(_ asyncActionCreator: AsyncActionCreator)
    #else
    func dispatch(asyncActionCreator: AsyncActionCreator)
    #endif

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously. Use this method if you want to wait for the state change
     triggered by the asynchronously generated action creator.

     This overloaded version of `dispatch` calls the provided `callback` as soon as the
     asynchronoously dispatched action has caused a new state calculation.

     - Note: If the ActionCreator does not dispatch an action, the callback block will never
     be called
     */
    #if swift(>=3)
    func dispatch(_ asyncActionCreator: AsyncActionCreator, callback: DispatchCallback?)
    #else
    func dispatch(asyncActionCreator: AsyncActionCreator, callback: DispatchCallback?)
    #endif


    /**
     An optional callback that can be passed to the `dispatch` method.
     This callback will be called when the dispatched action triggers a new state calculation.
     This is useful when you need to wait on a state change, triggered by an action (e.g. wait on
     a successful login). However, you should try to use this callback very seldom as it
     deviates slighlty from the unidirectional data flow principal.
     */
    associatedtype DispatchCallback = (State) -> Void

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
    associatedtype ActionCreator = (state: State, store: StoreType) -> Action?

    /// AsyncActionCreators allow the developer to wait for the completion of an async action.
    associatedtype AsyncActionCreator =
        (state: State, store: StoreType, actionCreatorCallback: (ActionCreator) -> Void) -> Void
}
