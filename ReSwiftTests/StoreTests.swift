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
// swiftlint:disable type_body_length
class StoreSpecs: QuickSpec {

    override func spec() {

        describe("#init") {

            it("Dispatches an Init action when it doesn't receive an initial state") {
                let reducer = MockReducer()
                let _ = Store<CounterState>(reducer: reducer, state: nil)

                expect(reducer.calledWithAction[0] is ReSwiftInit).to(beTrue())
            }

        }

        describe("#deinit") {

            it("Deinitializes when no reference is held") {
                var deInitCount = 0

                autoreleasepool {
                    let reducer = TestReducer()
                    let _ = DeInitStore(
                        reducer: reducer,
                        state: TestAppState(),
                        deInitAction: { deInitCount += 1 })
                }

                expect(deInitCount).to(equal(1))
            }

        }

        describe("#subscribe") {

            var store: Store<TestAppState>!
            var reducer: TestReducer!

            typealias TestSubscriber = TestStoreSubscriber<TestAppState>

            beforeEach {
                reducer = TestReducer()
                store = Store(reducer: reducer, state: TestAppState())
            }

            it("does not strongly capture an observer") {
                store = Store(reducer: reducer, state: TestAppState())
                var subscriber: TestSubscriber? = TestSubscriber()

                store.subscribe(subscriber!)
                expect(store.subscriptions.flatMap({ $0.subscriber }).count).to(equal(1))

                subscriber = nil
                expect(store.subscriptions.flatMap({ $0.subscriber })).to(beEmpty())
            }

            it("removes deferenced subscribers before notifying state changes") {
                store = Store(reducer: reducer, state: TestAppState())
                var subscriber1: TestSubscriber? = TestSubscriber()
                var subscriber2: TestSubscriber? = TestSubscriber()

                store.subscribe(subscriber1!)
                store.subscribe(subscriber2!)
                store.dispatch(SetValueAction(3))
                expect(store.subscriptions.count).to(equal(2))
                expect(subscriber1?.receivedStates.last?.testValue).to(equal(3))
                expect(subscriber2?.receivedStates.last?.testValue).to(equal(3))

                subscriber1 = nil
                store.dispatch(SetValueAction(5))
                expect(store.subscriptions.count).to(equal(1))
                expect(subscriber2?.receivedStates.last?.testValue).to(equal(5))

                subscriber2 = nil
                store.dispatch(SetValueAction(8))
                expect(store.subscriptions).to(beEmpty())
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
                let subscriber = DispatchingSubscriber(store: store)

                store.subscribe(subscriber)
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

                expect(store.subscriptions.count).to(equal(1))
            }

            it("ignores identical subscribers that provide substate selectors") {
                store = Store(reducer: reducer, state: TestAppState())
                let subscriber = TestStoreSubscriber<TestAppState>()

                store.subscribe(subscriber) { $0 }
                store.subscribe(subscriber) { $0 }

                expect(store.subscriptions.count).to(equal(1))
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

// Used for deinitialization test
class DeInitStore<State: StateType>: Store<State> {
    var deInitAction: (() -> Void)?

    deinit {
        deInitAction?()
    }

    required convenience init(
        reducer: AnyReducer,
        state: State?,
        deInitAction: () -> Void) {
            self.init(reducer: reducer, state: state, middleware: [])
            self.deInitAction = deInitAction
    }

    required init(reducer: AnyReducer, state: State?, middleware: [Middleware]) {
        super.init(reducer: reducer, state: state, middleware: middleware)
    }
}

// Needs to be class so that shared reference can be modified to inject store
class DispatchingReducer: Reducer {
    var store: Store<TestAppState>? = nil

    func handleAction(action: Action, state: TestAppState?) -> TestAppState {
        expect(self.store?.dispatch(SetValueAction(20))).to(raiseException(named:
            "SwiftFlow:IllegalDispatchFromReducer"))
        return state ?? TestAppState()
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable function_body_length
