//
//  StoreSubscriber.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyStoreSubscriber: class {
    func _newState(state: StateType)
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    typealias StoreSubscriberStateType

    func newState(state: StoreSubscriberStateType)

}

extension StoreSubscriber {
    public func _newState(state: StateType) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(typedState)
        }
    }
}
