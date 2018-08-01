//
//  StoreSubscriber.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

public protocol AnyStoreSubscriber: class {
    // swiftlint:disable:next identifier_name
    func _apply(state: Any)
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType

    func apply(state: StoreSubscriberStateType)
}

extension StoreSubscriber {
    // swiftlint:disable:next identifier_name
    public func _apply(state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            apply(state: typedState)
        }
    }
}
