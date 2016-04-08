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
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    #if swift(>=2.2)
    associatedtype StoreSubscriberStateType
    #else
    typealias StoreSubscriberStateType
    #endif

    func newState(state: StoreSubscriberStateType)
}

extension StoreSubscriber {
    public func _newState(state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(typedState)
        }
    }
}
