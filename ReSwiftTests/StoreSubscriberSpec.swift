//
//  StoreSubscriberSpec.swift
//  ReSwift
//
//  Created by Benji Encz on 1/23/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import XCTest
@testable import ReSwift

// swiftlint:disable function_body_length
class FilteredStoreSpec: XCTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }


    // #subscribe
    // allows to pass a state selector closure
    func testAllowsToPassAStateSelectorClosure() {
        let reducer = TestReducer()
        let store = Store(reducer: reducer, state: TestAppState())
        let subscriber = TestFilteredSubscriber()

        store.subscribe(subscriber) {
            $0.testValue
        }

        store.dispatch(SetValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)
    }

    // supports complex state selector closures
    func testSupportsComplexStateSelectorClosures() {
        let reducer = TestComplexAppStateReducer()
        let store = Store(reducer: reducer, state: TestComplexAppState())
        let subscriber = TestSelectiveSubscriber()

        store.subscribe(subscriber) {
            (
                $0.testValue,
                $0.otherState?.name
            )
        }

        store.dispatch(SetValueAction(5))
        store.dispatch(SetOtherStateAction(
            otherState: OtherState(name: "TestName", age: 99)
        ))

        XCTAssertEqual(subscriber.receivedValue.0, 5)
        XCTAssertEqual(subscriber.receivedValue.1, "TestName")
    }

}

class TestFilteredSubscriber: StoreSubscriber {
    var receivedValue: Int?

    func newState(_ state: Int?) {
        receivedValue = state
    }

}

/**
 Example of how you can select a substate. The return value from
 `selectSubstate` and the argument for `newState` need to match up.
 */
class TestSelectiveSubscriber: StoreSubscriber {
    var receivedValue: (Int?, String?)

    func newState(_ state: (Int?, String?)) {
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

struct TestComplexAppStateReducer: Reducer {
    func handleAction(_ action: Action, state: TestComplexAppState?) -> TestComplexAppState {
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
