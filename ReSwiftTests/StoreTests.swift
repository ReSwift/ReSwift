//
//  SwiftFlowTests.swift
//  SwiftFlowTests
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import XCTest
@testable import ReSwift

// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
class StoreSpecs: XCTestCase {

    typealias TestSubscriber = TestStoreSubscriber<TestAppState>

    var store: Store<TestAppState>!
    var reducer: TestReducer!

    override func setUp() {
      super.setUp()
      reducer = TestReducer()
      store = Store(reducer: reducer, state: TestAppState())
    }

    override func tearDown() {
      super.tearDown()
    }

    func testInit() {
      // init
      // Dispatches an Init action when it doesn't receive an initial state
      let reducer = MockReducer()
      let _ = Store<CounterState>(reducer: reducer, state: nil)

      XCTAssertTrue(reducer.calledWithAction[0] is ReSwiftInit)

    }

    func testDeInit() {
        // deinit
        // Deinitializes when no reference is held
        var deInitCount = 0

        autoreleasepool {
            let reducer = TestReducer()
            let _ = DeInitStore(
                reducer: reducer,
                state: TestAppState(),
                deInitAction: { deInitCount += 1 })
        }

        XCTAssertEqual(deInitCount, 1)
    }

    func testSubscribeNotStronglyCaptureObserver() {
        // subscribe
        // does not strongly capture an observer

        store = Store(reducer: reducer, state: TestAppState())
        var subscriber: TestSubscriber? = TestSubscriber()

        store.subscribe(subscriber!)
        XCTAssertEqual(store.subscriptions.flatMap({ $0.subscriber }).count, 1)

        subscriber = nil
        XCTAssertEqual(store.subscriptions.flatMap({ $0.subscriber }).count, 0)
    }

    func testSubscribeRemovesDereferencedSubscribers() {
        // removes deferenced subscribers before notifying state changes

        store = Store(reducer: reducer, state: TestAppState())
        var subscriber1: TestSubscriber? = TestSubscriber()
        var subscriber2: TestSubscriber? = TestSubscriber()

        store.subscribe(subscriber1!)
        store.subscribe(subscriber2!)
        store.dispatch(SetValueAction(3))
        XCTAssertEqual(store.subscriptions.count, 2)
        XCTAssertEqual(subscriber1?.receivedStates.last?.testValue, 3)
        XCTAssertEqual(subscriber2?.receivedStates.last?.testValue, 3)

        subscriber1 = nil
        store.dispatch(SetValueAction(5))
        XCTAssertEqual(store.subscriptions.count, 1)
        XCTAssertEqual(subscriber2?.receivedStates.last?.testValue, 5)

        subscriber2 = nil
        store.dispatch(SetValueAction(8))
        XCTAssertEqual(store.subscriptions.count, 0)
    }

    func testSubscribeDispatchesInitialValue() {
        // dispatches initial value upon subscription
        store = Store(reducer: reducer, state: TestAppState())
        let subscriber = TestStoreSubscriber<TestAppState>()

        store.subscribe(subscriber)
        store.dispatch(SetValueAction(3))

        XCTAssertEqual(subscriber.receivedStates.last?.testValue, 3)
    }

    func testSubscribeAllowsDispatchingFromObserver() {
        // allows dispatching from within an observer
        store = Store(reducer: reducer, state: TestAppState())
        let subscriber = DispatchingSubscriber(store: store)

        store.subscribe(subscriber)
        store.dispatch(SetValueAction(2))

        XCTAssertEqual(store.state.testValue, 5)
    }

    func testSubscribeDoesNotDispatchValueAfterUnsubscribe() {
        // does not dispatch value after subscriber unsubscribes
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

        XCTAssertEqual(subscriber.receivedStates.count, 4)

        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 4]
            .testValue, 5)

        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 3]
            .testValue, 10)

        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 2]
            .testValue, 25)

        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 1]
            .testValue, 20)
    }

    func testSubscribeIgnoresIdenticalSubscribers() {
        // ignores identical subscribers
        store = Store(reducer: reducer, state: TestAppState())
        let subscriber = TestStoreSubscriber<TestAppState>()

        store.subscribe(subscriber)
        store.subscribe(subscriber)

        XCTAssertEqual(store.subscriptions.count, 1)
    }

    func testSubscribeIgnoresIdenticalSubscribersThatProvideSubstate() {
        // ignores identical subscribers that provide substate selectors
        store = Store(reducer: reducer, state: TestAppState())
        let subscriber = TestStoreSubscriber<TestAppState>()

        store.subscribe(subscriber) { $0 }
        store.subscribe(subscriber) { $0 }

        XCTAssertEqual(store.subscriptions.count, 1)
    }

    func testDispatchReturnsTheDispatchedAction() {
        // dispatch
        // returns the dispatched action
        let action = SetValueAction(10)
        let returnValue = store.dispatch(action)

        XCTAssertEqual((returnValue as? SetValueAction)?.value, action.value)
    }

    func testThrowsExceptionWhenReducerDispatchesAction() {
        // throws an exception when a reducer dispatches an action
        // Expectation lives in the `DispatchingReducer` class
        let reducer = DispatchingReducer()
        store = Store(reducer: reducer, state: TestAppState())
        reducer.store = store
        store.dispatch(SetValueAction(10))
    }

    func testAcceptsActionCreators() {
        // accepts action creators") {
        store.dispatch(SetValueAction(5))

        let doubleValueActionCreator: Store<TestAppState>.ActionCreator = { state, store in
            return SetValueAction(state.testValue! * 2)
        }

        _ = store.dispatch(doubleValueActionCreator)

        XCTAssertEqual(store.state.testValue, 10)
    }

    func testAcceptsAsyncActionCreators() {
        // accepts async action creators
        let asyncActionCreator: Store<TestAppState>.AsyncActionCreator = { _, _, callback in
            let queue = DispatchQueue.global()
            queue.async {
                // Provide the callback with an action creator
                callback { state, store in
                    return SetValueAction(5)
                }
            }
        }

        store.dispatch(asyncActionCreator)

        XCTAssertNil(self.store.state.testValue)
        wait(1) {
            XCTAssertEqual(self.store.state.testValue, 5)
        }
    }

    func testCallsTheCallbackOnceUpdateFromAsyncComplete() {
        // calls the callback once state update from async action is complete
        let asyncActionCreator: Store<TestAppState>.AsyncActionCreator = { _, _, callback in
            let queue = DispatchQueue.global()
            queue.async {
                // Provide the callback with an action creator
                callback { state, store in
                    return SetValueAction(5)
                }
            }
        }

        let promise = expectation(description: "wait")
        self.store.dispatch(asyncActionCreator) { newState in
            if newState.testValue == 5 {
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: Double(1)) { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
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

    func handleAction(_ action: Action, state: TestAppState?) -> TestAppState {
        let raised = NSExceptionCatcher.caughtException {
          self.store?.dispatch(SetValueAction(20))
        }

        XCTAssertTrue(raised)
        return state ?? TestAppState()
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable function_body_length
