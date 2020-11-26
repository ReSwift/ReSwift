//
//  StoreType.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/28/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

/**
 Defines the interface of Stores in ReSwift. `Store` is the default implementation of this
 interface. Applications have a single store that stores the entire application state.
 Stores receive actions and use reducers combined with these actions, to calculate state changes.
 Upon every state update a store informs all of its subscribers.
 */
public protocol StoreType: DispatchingStoreType {

    associatedtype State

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
     - note: Subscriptions are not ordered, so an order of state updates cannot be guaranteed.
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
     - note: Subscriptions are not ordered, so an order of state updates cannot be guaranteed.
     */
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

    /**
     Subscribes the provided subscriber to this store.
     Subscribers will receive a call to `newState` whenever the
     state in this store changes and the subscription decides to forward
     state update.

     This variation is used when substate conforms to `Equatable` and
     `automaticallySkipsRepeats` is enabled on the store.

     - parameter subscriber: Subscriber that will receive store updates
     - parameter transform: A closure that receives a simple subscription and can return a
       transformed subscription. Subscriptions can be transformed to only select a subset of the
       state, or to skip certain state updates.
     - note: Subscriptions are not ordered, so an order of state updates cannot be guaranteed.
     */
    func subscribe<SelectedState: Equatable, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

    /**
     Unsubscribes the provided subscriber. The subscriber will no longer
     receive state updates from this store.

     - parameter subscriber: Subscriber that will be unsubscribed
     */
    func unsubscribe(_ subscriber: AnyStoreSubscriber)

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
     */
    func dispatch(_ actionCreator: ActionCreator)

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously.
     */
    func dispatch(_ asyncActionCreator: AsyncActionCreator)

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously. Use this method if you want to wait for the state change
     triggered by the asynchronously generated action creator.

     This overloaded version of `dispatch` calls the provided `callback` as soon as the
     asynchronoously dispatched action has caused a new state calculation.

     - Note: If the ActionCreator does not dispatch an action, the callback block will never
     be called
     */
    func dispatch(_ asyncActionCreator: AsyncActionCreator, callback: DispatchCallback?)

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
    associatedtype ActionCreator = (_ state: State, _ store: StoreType) -> Action?

    /// AsyncActionCreators allow the developer to wait for the completion of an async action.
    associatedtype AsyncActionCreator =
        (_ state: State, _ store: StoreType,
         _ actionCreatorCallback: (ActionCreator) -> Void) -> Void
}
