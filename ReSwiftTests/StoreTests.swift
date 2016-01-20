//
//  SwiftFlowTests.swift
//  SwiftFlowTests
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import ReSwift

// swiftlint:disable function_body_length
class StoreSpecs: QuickSpec {

    override func spec() {

        describe("#init") {

            it("Dispatches an Init action when it doesn't receive an initial state") {
                let reducer = MockReducer()
                let _ = Store<CounterState>(reducer: reducer, state: nil)

                expect(reducer.calledWithAction[0] is SwiftFlowInit).to(beTrue())
            }

        }

        describe("#subscribe") {

            var store: Store<TestAppState>!
            var reducer: TestReducer!

            beforeEach {
                reducer = TestReducer()
                store = Store(reducer: reducer, state: TestAppState())
            }

            it("dispatches initial value upon subscription") {
                store = Store(reducer: reducer, state: TestAppState())
                let subscriber = TestStoreSubscriber<TestAppState>()

                store.subscribe(subscriber)
                store.dispatch(SetValueAction(3))

                expect(subscriber.receivedStates.last?.testValue).to(equal(3))
            }

            it("allows dispatching from within an observer") {
                store = Store(reducer: reducer, state: TestAppState())
                store.subscribe(DispatchingSubscriber(store: store))

                store.dispatch(SetValueAction(2))

                expect(store.state.testValue).to(equal(5))
            }

            it("does not dispatch value after subscriber unsubscribes") {
                store = Store(reducer: reducer, state: TestAppState())
                let subscriber = TestStoreSubscriber<TestAppState>()

                store.dispatch(SetValueAction(5))
                store.subscribe(subscriber)
                store.dispatch(SetValueAction(10))

                store.unsubscribe(subscriber)
                // Following value is missed due to not being subscribed:
                store.dispatch(SetValueAction(15))
                store.dispatch(SetValueAction(25))

                store.subscribe(subscriber)

                store.dispatch(SetValueAction(20))

                expect(subscriber.receivedStates.count).to(equal(4))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 4]
                    .testValue).to(equal(5))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 3]
                    .testValue).to(equal(10))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 2]
                    .testValue).to(equal(25))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 1]
                    .testValue).to(equal(20))
            }

            it("ignores identical subscribers") {
                store = Store(reducer: reducer, state: TestAppState())
                let subscriber = TestStoreSubscriber<TestAppState>()

                store.subscribe(subscriber)
                store.subscribe(subscriber)

                expect(store.subscribers.count).to(equal(1))
            }

        }

        describe("#dispatch") {

            var store: Store<TestAppState>!
            var reducer: TestReducer!

            beforeEach {
                reducer = TestReducer()
                store = Store(reducer: reducer, state: TestAppState())
            }

            it("returns the dispatched action") {
                let action = SetValueAction(10)
                let returnValue = store.dispatch(action)

                expect((returnValue as? SetValueAction)?.value).to(equal(action.value))
            }

            it("throws an exception when a reducer dispatches an action") {
                // Expectation lives in the `DispatchingReducer` class
                let reducer = DispatchingReducer()
                store = Store(reducer: reducer, state: TestAppState())
                reducer.store = store
                store.dispatch(SetValueAction(10))
            }

            it("accepts action creators") {
                store.dispatch(SetValueAction(5))

                let doubleValueActionCreator: Store<TestAppState>.ActionCreator = { state, store in
                    return SetValueAction(state.testValue! * 2)
                }

                store.dispatch(doubleValueActionCreator)

                expect(store.state.testValue).to(equal(10))
            }

            it("accepts async action creators") {
                let asyncActionCreator: Store<TestAppState>.AsyncActionCreator = { _, _, callback in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        // Provide the callback with an action creator
                        callback { state, store in
                            return SetValueAction(5)
                        }
                    }
                }

                store.dispatch(asyncActionCreator)

                expect(store.state.testValue).toEventually(equal(5))
            }

            it("calls the callback once state update from async action is complete") {
                let asyncActionCreator: Store<TestAppState>.AsyncActionCreator = { _, _, callback in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        // Provide the callback with an action creator
                        callback { state, store in
                            return SetValueAction(5)
                        }
                    }
                }

                waitUntil { fulfill in
                    store.dispatch(asyncActionCreator) { newState in
                        if newState.testValue == 5 {
                            fulfill()
                        }
                    }
                }
            }

        }

    }

}


// Needs to be class so that shared reference can be modified to inject store
class DispatchingReducer: Reducer {
    var store: Store<TestAppState>? = nil

    func handleAction(state: TestAppState?, action: Action) -> TestAppState {
        expect(self.store?.dispatch(SetValueAction(20))).to(raiseException(named:
            "SwiftFlow:IllegalDispatchFromReducer"))
        return state ?? TestAppState()
    }
}

// swiftlint:enable function_body_length
