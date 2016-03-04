//
//  StoreSubscriberSpec.swift
//  ReSwift
//
//  Created by Benji Encz on 1/23/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Quick
import Nimble
@testable import ReSwift

// swiftlint:disable function_body_length
class FilteredStoreSpec: QuickSpec {

    override func spec() {

        describe("#subscribe") {

            it("allows to pass a state selector closure") {
                let reducer = TestReducer()
                let store = Store(reducer: reducer, state: TestAppState())
                let subscriber = TestFilteredSubscriber()

                store.subscribe(subscriber) {
                    $0.testValue
                }

                store.dispatch(SetValueAction(3))

                expect(subscriber.receivedValue).to(equal(3))
            }

            it("supports complex state selector closures") {
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

                expect(subscriber.receivedValue.0).to(equal(5))
                expect(subscriber.receivedValue.1).to(equal("TestName"))
            }

            it("supports reducers that access sub state via protocols") {

                let reducer = CombinedReducer([TestComplexAppStateReducer(), TestHasOtherStateReducer()])
                let store = Store(reducer: reducer, state: TestComplexAppState())
                let subscriber1 = TestSelectiveSubscriber()
                let subscriber2 = TestOtherStateSubscriber()
                store.subscribe(subscriber1) {
                    (
                        $0.testValue,
                        $0.otherState?.name
                    )
                }
                store.subscribe(subscriber2) {
                    (
                        $0.otherState
                    )
                }

                store.dispatch(SetValueAction(5))
                store.dispatch(SetOtherStateAction(
                    otherState: OtherState(name: "TestName", age: 99)
                ))

                expect(subscriber1.receivedValue.0).to(equal(5))
                expect(subscriber1.receivedValue.1).to(equal("TestName"))

                store.dispatch(SetOtherStateAgeAction(age: 10))
                store.dispatch(SetOtherStateNameAction(name: "Bloop"))

                expect(subscriber2.receivedValue?.age).to(equal(10))
                expect(subscriber2.receivedValue?.name).to(equal("Bloop"))
            }
        }
    }
}

class TestFilteredSubscriber: StoreSubscriber {
    var receivedValue: Int?

    func newState(state: Int?) {
        receivedValue = state
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

protocol HasOtherState {
    var otherState: OtherState? { get set }
}

struct OtherState {
    var name: String?
    var age: Int?
}

struct TestComplexAppState: StateType, HasOtherState {
    var testValue: Int?
    var otherState: OtherState?
}

struct TestComplexAppStateReducer: Reducer {
    func handleAction(action: Action, state: TestComplexAppState?) -> TestComplexAppState? {
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

/*
 Test reducers that access substates through Has<SomeState> protocol
 */
class TestOtherStateSubscriber: StoreSubscriber {
    var receivedValue: OtherState?

    func newState(state: OtherState?) {
        receivedValue = state
    }
}

struct TestHasOtherStateReducer: Reducer {
    func handleAction(action: Action, state: HasOtherState?) -> HasOtherState? {

        if var state = state {
            var otherState = state.otherState ?? OtherState()

            switch action {
            case let action as SetOtherStateNameAction:
                otherState.name = action.name
                break
            case let action as SetOtherStateAgeAction:
                otherState.age = action.age
                break
            default:
                break
            }
            state.otherState = otherState
            return state
        }
        return state
    }
}

struct SetOtherStateNameAction: Action {
    var name: String
}

struct SetOtherStateAgeAction: Action {
    var age: Int
}