//
//  StoreSubscriberTests.swift
//  ReSwift
//
//  Created by Benji Encz on 1/23/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

class StoreSubscriberTests: XCTestCase {

    /**
     it allows to pass a state selector closure
     */
    func testAllowsSelectorClosure() {
        let reducer = TestReducer()
        let store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscription()
            .select { $0.testValue }
            .subscribe(subscriber)

        store.dispatch(SetValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(SetValueAction(nil))

        XCTAssertEqual(subscriber.receivedValue, nil)
    }

    /**
     it supports complex state selector closures
     */
    func testComplexStateSelector() {
        let reducer = TestComplexAppStateReducer()
        let store = Store(reducer: reducer.handleAction, state: TestComplexAppState())
        let subscriber = TestSelectiveSubscriber()

        store.subscription()
            .select {
                ($0.testValue, $0.otherState?.name)
            }
            .subscribe(subscriber)

        store.dispatch(SetValueAction(5))
        store.dispatch(SetOtherStateAction(
            otherState: OtherState(name: "TestName", age: 99)
        ))

        XCTAssertEqual(subscriber.receivedValue.0, 5)
        XCTAssertEqual(subscriber.receivedValue.1, "TestName")
    }

    /**
     it supports splitting the subscriber into multiple state selector closures
     */
    func testSplittingStateSelector() {
        let reducer = TestComplexAppStateReducer()
        let store = Store(reducer: reducer.handleAction, state: TestComplexAppState())
        let firstSubscriber = TestFilteredSubscriber<Int?>()

        let subscription = store.subscription()
        subscription.select { $0.testValue }
            .subscribe(firstSubscriber)

        let secondSubscriber = TestFilteredSubscriber<String?>()
        subscription.select { $0.otherState?.name }
            .subscribe(secondSubscriber)

        store.dispatch(SetValueAction(5))
        store.dispatch(SetOtherStateAction(
            otherState: OtherState(name: "TestName", age: 99)
        ))

        XCTAssertEqual(firstSubscriber.receivedValue, 5)
        XCTAssertEqual(secondSubscriber.receivedValue, "TestName")
    }

    // TODO: Add tests for splitting after `select`, `skip`, and `only`

    // TODO: Add test for subscribing and splitting (I dont think this works right now)
    // eg: `let sub = subscription(); sub.subscribe(subscriber); sub.select({ $0.xyz }).subscribe(otherSubscriber)

    /**
     it does not notify subscriber for unchanged substate state when using `skipRepeats`.
     */
    func testUnchangedStateSelector() {
        let reducer = TestReducer()
        var state = TestAppState()
        state.testValue = 3
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscription()
            .select { $0.testValue }
            .skip(when: ==)
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(SetValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    /**
     it does not notify subscriber for unchanged substate state when using the default
     `skipRepeats` implementation.
     */
    func testUnchangedStateSelectorDefaultSkipRepeats() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<String>()

        store.subscription()
            .select { $0.testValue }
            .skip(when: ==)
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    /**
     it skips repeated state values by when `skipRepeats` returns `true`.
     */
    func testSkipsStateUpdatesForCustomEqualityChecks() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscription()
            .select { $0.substate }
            .skip { $0.value == $1.value }
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(SetCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testInheritsSkipEquatableActivationFromStore() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            middleware: [],
            automaticallySkipsEquatable: true)
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscription()
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testInheritsSkipEquatableDeactivationFromStore() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            middleware: [],
            automaticallySkipsEquatable: false)
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscription()
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testSkipWhen() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscription()
            .select { $0.substate }
            .skip { $0.value == $1.value }
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(SetCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testOnlyWhen() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscription()
            .select { $0.substate }
            .only {
                $0.value != $1.value
            }
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(SetCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }
}

class TestFilteredSubscriber<T>: StoreSubscriber {
    var receivedValue: T!
    var newStateCallCount = 0

    func newState(state: T) {
        receivedValue = state
        newStateCallCount += 1
    }

}

/**
 Example of how you can select a substate. The return value from
 `selectSubstate` and the argument for `newState` need to match up.
 */
class TestSelectiveSubscriber: StoreSubscriber {
    var receivedValue: (Int?, String?)

    func newState(state: (Int?, String?)) {
        receivedValue = state
    }
}

struct TestComplexAppState: StateType {
    var testValue: Int?
    var otherState: OtherState?
}

struct OtherState {
    var name: String?
    var age: Int?
}

struct TestComplexAppStateReducer {
    func handleAction(action: Action, state: TestComplexAppState?) -> TestComplexAppState {
        var state = state ?? TestComplexAppState()

        switch action {
        case let action as SetValueAction:
            state.testValue = action.value
            return state
        case let action as SetOtherStateAction:
            state.otherState = action.otherState
        default:
            break
        }

        return state
    }
}

struct SetOtherStateAction: Action {
    var otherState: OtherState
}
