//
//  TestFakes.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/24/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import Foundation
import ReSwift

struct TestAppState {
    var testValue: Int?

    init(testValue: Int? = nil) {
        self.testValue = testValue
    }
}

struct TestStringAppState {
    var testValue: String

    init() {
        testValue = "Initial"
    }
}

extension TestStringAppState: Equatable {
    static func == (lhs: TestStringAppState, rhs: TestStringAppState) -> Bool {
        return lhs.testValue == rhs.testValue
    }
}

struct TestNonEquatable {
    var testValue: NonEquatable

    init() {
        testValue = NonEquatable()
    }
}

struct NonEquatable {
    var testValue: String

    init() {
        testValue = "Initial"
    }
}

struct TestCustomAppState {
    var substate: TestCustomSubstate

    init(substate: TestCustomSubstate) {
        self.substate = substate
    }

    init(substateValue value: Int = 0) {
        self.substate = TestCustomSubstate(value: value)
    }

    struct TestCustomSubstate {
        var value: Int
    }
}

struct NoOpAction: Action {}

struct SetValueAction: Action {

    let value: Int?
    static let type = "SetValueAction"

    init (_ value: Int?) {
        self.value = value
    }
}

struct SetValueStringAction: Action {

    var value: String
    static let type = "SetValueStringAction"

    init (_ value: String) {
        self.value = value
    }
}

struct SetCustomSubstateAction: Action {

    var value: Int
    static let type = "SetCustomSubstateAction"

    init (_ value: Int) {
        self.value = value
    }
}

struct SetNonEquatableAction: Action {
    var value: NonEquatable
    static let type = "SetNonEquatableAction"

    init (_ value: NonEquatable) {
        self.value = value
    }
}

struct TestReducer {
    func handleAction(action: Action, state: TestAppState?) -> TestAppState {
        var state = state ?? TestAppState()

        switch action {
        case let action as SetValueAction:
            state.testValue = action.value
            return state
        default:
            return state
        }
    }
}

struct TestValueStringReducer {
    func handleAction(action: Action, state: TestStringAppState?) -> TestStringAppState {
        var state = state ?? TestStringAppState()

        switch action {
        case let action as SetValueStringAction:
            state.testValue = action.value
            return state
        default:
            return state
        }
    }
}

struct TestCustomAppStateReducer {
    func handleAction(action: Action, state: TestCustomAppState?) -> TestCustomAppState {
        var state = state ?? TestCustomAppState()

        switch action {
        case let action as SetCustomSubstateAction:
            state.substate.value = action.value
            return state
        default:
            return state
        }
    }
}

struct TestNonEquatableReducer {
    func handleAction(action: Action, state: TestNonEquatable?) ->
        TestNonEquatable {
        var state = state ?? TestNonEquatable()

        switch action {
        case let action as SetNonEquatableAction:
            state.testValue = action.value
            return state
        default:
            return state
        }
    }
}

class TestStoreSubscriber<T>: StoreSubscriber {
    var receivedStates: [T] = []

    func newState(state: T) {
        receivedStates.append(state)
    }
}

class BlockSubscriber<S>: StoreSubscriber {
    typealias StoreSubscriberStateType = S
    private let block: (S) -> Void

    init(block: @escaping (S) -> Void) {
        self.block = block
    }

    func newState(state: S) {
        self.block(state)
    }
}

class DispatchingSubscriber: StoreSubscriber {
    var store: Store<TestAppState>

    init(store: Store<TestAppState>) {
        self.store = store
    }

    func newState(state: TestAppState) {
        // Test if we've already dispatched this action to
        // avoid endless recursion
        if state.testValue != 5 {
            self.store.dispatch(SetValueAction(5))
        }
    }
}

class CallbackStoreSubscriber<T>: StoreSubscriber {

    let handler: (T) -> Void

    init(handler: @escaping (T) -> Void) {
        self.handler = handler
    }

    func newState(state: T) {
        handler(state)
    }
}
