//
//  ObservableTestFakes.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import ReSwift

struct ObservableTestReducer: ObservableReducer {
    func handleAction(action: Action, state: TestAppState) -> TestAppState {
        switch action {
        case let action as SetValueAction:
            return TestAppState(testValue: action.value)
        default:
            return state
        }
    }
}

struct ObservableTestValueStringReducer: ObservableReducer {
    func handleAction(action: Action, state: TestStringAppState) -> TestStringAppState {
        switch action {
        case let action as SetValueStringAction:
            return TestStringAppState(testValue: action.value)
        default:
            return state
        }
    }
}

class ObservableTestStoreSubscriber<T> {
    var receivedStates: [T] = []
    var subscription: (T) -> Void = { _ in }

    init() {
        subscription = { self.receivedStates.append($0) }
    }

    func newState(state: T) {
        receivedStates.append(state)
    }
}
