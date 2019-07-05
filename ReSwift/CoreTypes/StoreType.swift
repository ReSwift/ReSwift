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

    associatedtype State: StateType

    /// The current state stored in the store.
    var state: State { get }

    /**
     The main dispatch function that is used by all convenience `dispatch` methods.
     This dispatch function can be extended by providing middlewares.
     */
    var dispatchFunction: DispatchFunction! { get }
}
