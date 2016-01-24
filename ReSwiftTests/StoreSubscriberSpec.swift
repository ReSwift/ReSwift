//
//  StoreSubscriberSpec.swift
//  ReSwift
//
//  Created by Benji Encz on 1/23/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import ReSwift

// swiftlint:disable function_body_length
class StoreSubsriberSpec: QuickSpec {

    override func spec() {

        var store: Store<TestComplexAppState>!
        var reducer: TestComplexAppStateReducer!

        describe("Substate Selection") {

            beforeEach {
                reducer = TestComplexAppStateReducer()
                store = Store(reducer: reducer, state: TestComplexAppState())
            }

            it("it allows subscribers to subselect a state") {
                let subscriber = TestSelectiveSubscriber()

                store.subscribe(subscriber)
                store.dispatch(SetValueAction(5))
                store.dispatch(SetOtherStateAction(
                    otherState: OtherState(name: "TestName", age: 99)
                ))

                expect(subscriber.receivedValue.0).to(equal(5))
                expect(subscriber.receivedValue.1).to(equal("TestName"))
            }

            it("is possible to select a state via protocols") {
                let subscriber = TestSelectiveSubscriberProtocol()

                store.subscribe(subscriber)
                store.dispatch(SetOtherStateAction(
                    otherState: OtherState(name: "TestName", age: 99)
                ))

                expect(subscriber.receivedValue?.name).to(equal("TestName"))
                expect(subscriber.receivedValue?.age).to(equal(99))
            }

            it("doesn't use the subselect if it's incorrect") {
                let subscriber = TestIncorrectSelectiveSubscriber()

                store.subscribe(subscriber)
                store.dispatch(SetOtherStateAction(
                    otherState: OtherState(name: "TestName", age: 99)
                ))

                expect(subscriber.receivedValue.0).to(beNil())
                expect(subscriber.receivedValue.1).to(beNil())
            }
        }

    }

}

// MARK: Test Types for Substate Selection via Selector

/**
    Example of how you can select a substate. The return value from
    `selectSubstate` and the argument for `newState` need to match up.
*/
class TestSelectiveSubscriber: StoreSubscriber {
    var receivedValue: (Int?, String?)

    func selectSubstate(state: TestComplexAppState) -> (Int?, String?) {
        return (
            state.testValue,
            state.otherState?.name
        )
    }

    func newState(state: (Int?, String?)) {
        receivedValue = state
    }

}

struct TestComplexAppState: StateType, ContainsOtherState {
    var testValue: Int?
    var otherState: OtherState?
}

struct OtherState {
    var name: String?
    var age: Int?
}

struct TestComplexAppStateReducer: Reducer {
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

// MARK: Test Types for Substate Selection via Protocol

protocol ContainsOtherState {
    var otherState: OtherState? { get }
}

class TestSelectiveSubscriberProtocol: StoreSubscriber {
    var receivedValue: OtherState?

    func newState(state: ContainsOtherState) {
        receivedValue = state.otherState
    }

}

// MARK: Test Types for Incorrect type in Select Substate

class TestIncorrectSelectiveSubscriber: StoreSubscriber {
    var receivedValue: (Int?, String?)

    // NOTE: the state argument is purposefully false here
    func selectSubstate(state: String) -> (Int?, String?) {
        return (
            0,
            ""
        )
    }

    func newState(state: (Int?, String?)) {
        receivedValue = state
    }

}
