//
//  StoreSubscriber.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyStoreSubscriber: class {
    // swiftlint:disable:next identifier_name
    func _initialState(state: Any)

    // swiftlint:disable:next identifier_name
    func _newState(oldState: Any, state: Any, automaticallySkipsEquatable: Bool)
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType

    func newState(state: StoreSubscriberStateType)
}

extension StoreSubscriber where StoreSubscriberStateType: Equatable {
    // swiftlint:disable:next identifier_name
    public func _newState(oldState: Any, state: Any, automaticallySkipsEquatable: Bool) {
        if let typedState = state as? StoreSubscriberStateType {
            if automaticallySkipsEquatable {
                if let typedOldState = oldState as? StoreSubscriberStateType,
                    typedState != typedOldState {
                    newState(state: typedState)
                }
            } else {
                newState(state: typedState)
            }
        }
    }
}

extension StoreSubscriber {

    // swiftlint:disable:next identifier_name
    public func _initialState(state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(state: typedState)
        }
    }

    // swiftlint:disable:next identifier_name
    public func _newState(oldState: Any, state: Any, automaticallySkipsEquatable: Bool) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(state: typedState)
        }
    }
}
