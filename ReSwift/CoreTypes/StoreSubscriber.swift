//
//  StoreSubscriber.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

public protocol AnyStoreSubscriber: AnyObject {
    // swiftlint:disable:next identifier_name
    func _newState(state: Any)
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType

    func newState(state: StoreSubscriberStateType)
}

extension StoreSubscriber {
    // swiftlint:disable:next identifier_name
    public func _newState(state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(state: typedState)
        }
    }
}
