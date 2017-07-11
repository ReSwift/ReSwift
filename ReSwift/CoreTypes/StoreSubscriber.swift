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

final class AnonymousSubscriber<T>: StoreSubscriber {
    let closure: (T) -> Void

    init(closure: @escaping (T) -> Void) {
        self.closure = closure
    }

    func newState(state: T) {
        self.closure(state)
    }
}

extension Store {

    // Someone needs to retain `AnonymousSubscriber`; could store in a global dictionary or similar
    // then return a unique token from this function, such that when token unregisters, anonymous wrapper is freed.
    func subscribe(closure: @escaping (Store.State) -> Void) {
        self.subscribe(AnonymousSubscriber(closure: closure))
    }

}


