//
//  Store.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 11/28/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

public protocol Store {

    /// The current state stored in the store
    var appState: StateType { get }

    /**
     Subscribes the provided subscriber to this store.
     Subscribers will receive a call to `newState` whenever the
     state in this store changes.

     - parameter subscriber: Subscriber that will receive store updates
     */
    func subscribe(subscriber: AnyStoreSubscriber)

    /**
     Unsubscribes the provided subscriber. The subscriber will no longer
     receive state updates from this store.

     - parameter subscriber: Subscriber that will be unsubscribed
    */
    func unsubscribe(subscriber: AnyStoreSubscriber)

    /**
     Dispatches an action. This is the simplest way to modify the stores state.

     Example of dispatching an action:
     ```swift
     store.dispatch( CounterAction.IncreaseCounter )
     ```
     - parameter action: The action that is being dispatched to the store
    */
    func dispatch(action: ActionType)

    /**
     Dispatches an action creator to the store. Action creators are functions that generate
     actions. They are called by the store and receive the current state of the application
     and a reference to the store as their input.

     Based on that input the action creator can either return an action or not. Alternatively
     the action creator can also perform an asynchronous operation and dispatch a new action
     at the end of it.

     Example of an action creator:
     ```swift
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
     ```swift
     store.dispatch( noteActionCreatore.deleteNote(3) )
     ```
     */
    func dispatch(actionCreatorProvider: ActionCreator)

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously. Use this method if you want to wait for the state change
     triggered by the asynchronously generated action creator.
     */
    func dispatch(asyncActionCreatorProvider: AsyncActionCreator)

    /**
     Dispatches an action and calls the callback as soon as the action has been processed.
     You will receive the updated store state as part of this callback.

     Example of dispatching an action and implementing a callback:
     ```swift
     store.dispatch( CounterAction.IncreaseCounter ) { state in
        print("New state: \(state)")
     }
     ```
     - parameter action: The action that is being dispatched to the store
     */
    func dispatch(action: ActionType, callback: DispatchCallback?)
    func dispatch(actionCreatorProvider: ActionCreator, callback: DispatchCallback?)
    func dispatch(asyncActionCreatorProvider: AsyncActionCreator, callback: DispatchCallback?)
}

public typealias DispatchCallback = (StateType) -> Void
public typealias ActionCreator = (state: StateType, store: Store) -> ActionType?

/// AsyncActionCreators allow the developer to wait for the completion of an async action
public typealias AsyncActionCreator = (state: StateType, store: Store,
    actionCreatorCallback: ActionCreator -> Void) -> Void
