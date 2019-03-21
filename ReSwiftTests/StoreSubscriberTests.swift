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

        store.subscribe(subscriber) {
            $0.select { $0.testValue }
        }

        store.dispatch(SetValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(SetValueAction(nil))

        #if swift(>=4.1)
            XCTAssertEqual(subscriber.receivedValue, .some(.none))
        #else
            XCTAssertEqual(subscriber.receivedValue, nil)
        #endif
    }

    /**
     it supports complex state selector closures
     */
    func testComplexStateSelector() {
        let reducer = TestComplexAppStateReducer()
        let store = Store(reducer: reducer.handleAction, state: TestComplexAppState())
        let subscriber = TestSelectiveSubscriber()

        store.subscribe(subscriber) {
            $0.select {
                ($0.testValue, $0.otherState?.name)
            }
        }
        store.dispatch(SetValueAction(5))
        store.dispatch(SetOtherStateAction(
            otherState: OtherState(name: "TestName", age: 99)
        ))

        XCTAssertEqual(subscriber.receivedValue.0, 5)
        XCTAssertEqual(subscriber.receivedValue.1, "TestName")
    }

    /**
     it does not notify subscriber for unchanged substate state when using `skipRepeats`.
     */
    func testUnchangedStateSelector() {
        let reducer = TestReducer()
        var state = TestAppState()
        state.testValue = 3
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscribe(subscriber) {
            $0.select {
                $0.testValue
            }.skipRepeats {
                return $0 == $1
            }
        }

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

        store.subscribe(subscriber) {
            $0.select { $0.testValue }.skipRepeats()
        }

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

        store.subscribe(subscriber) {
            $0.select { $0.substate }
                .skipRepeats { $0.value == $1.value }
        }

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(SetCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testPassesOnDuplicateSubstateUpdatesByDefault() {
        let reducer = TestNonEquatableReducer()
        let state = TestNonEquatable()
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<NonEquatable>()

        store.subscribe(subscriber) {
            $0.select { $0.testValue }
        }

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(SetNonEquatableAction(NonEquatable()))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testPassesOnDuplicateSubstateWhenSkipsFalse() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(reducer: reducer.handleAction, state: state, middleware: [], automaticallySkipsRepeats: false)
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0.select { $0.testValue }
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testSkipsStateUpdatesForEquatableStateByDefault() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(reducer: reducer.handleAction, state: state, middleware: [])
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testSkipsStateUpdatesForEquatableSubStateByDefault() {
        let reducer = TestNonEquatableReducer()
        let state = TestNonEquatable()
        let store = Store(reducer: reducer.handleAction, state: state)
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0.select { $0.testValue.testValue }
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testPassesOnDuplicateStateUpdatesInCustomizedStore() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(reducer: reducer.handleAction, state: state, middleware: [], automaticallySkipsRepeats: false)
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscribe(subscriber)

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

        store.subscribe(subscriber) {
            $0.select { $0.substate }
                .skip { $0.value == $1.value }
        }

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

        store.subscribe(subscriber) {
            $0.select { $0.substate }
                .only { $0.value != $1.value }
        }

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
