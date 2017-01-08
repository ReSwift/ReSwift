//
//  StoreSubscriber.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyStoreSubscriber: class {
    func _newState<T: Any>(state: T, oldState: T?)
    func _newEquatableState<T: Equatable>(state: T, oldState: T?)
    func _newOptionalEquatableState<T: Equatable>(state: T?, oldState: T??)
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType

    func newState(state: StoreSubscriberStateType)
}

extension StoreSubscriber {
    public func _newState<T: Any>(state: T, oldState: T? = nil) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(state: typedState)
        }
    }

    public func _newEquatableState<T: Equatable>(state: T, oldState: T?) {
        if let oldState = oldState,
            state == oldState {
            return
        }

        if let typedState = state as? StoreSubscriberStateType {
            newState(state: typedState)
        }
    }

    public func _newOptionalEquatableState<T: Equatable>(state: T?, oldState: T??) {
        if let oldState = oldState,
            state == oldState {
            return
        }

        if let typedState = state as? StoreSubscriberStateType {
            newState(state: typedState)
        }
    }
}
