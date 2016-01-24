//
//  StoreSubscriber.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyStoreSubscriber: class {
    func _newState(state: Any)
    func _selectSubstate(state: StateType) -> Any
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    typealias StoreSubscriberStateType
    typealias AppSpecificState

    func newState(state: StoreSubscriberStateType)
    func selectSubstate(state: AppSpecificState) -> StoreSubscriberStateType
}

extension StoreSubscriber {
    public func _newState(state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(typedState)
        }
    }

    public func _selectSubstate(state: StateType) -> Any {
        if let typedState = state as? AppSpecificState {
            return selectSubstate(typedState)
        }

        return state
    }

    public func selectSubstate(state: StoreSubscriberStateType) -> StoreSubscriberStateType {
        return state
    }
}
