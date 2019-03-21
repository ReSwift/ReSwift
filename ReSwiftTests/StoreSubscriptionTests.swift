//
//  StoreSubscriptionTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import XCTest
/**
 @testable import for testing of `Store.subscriptions`
 */
@testable import ReSwift

class StoreSubscriptionTests: XCTestCase {

    typealias TestSubscriber = TestStoreSubscriber<TestAppState>

    var store: Store<TestAppState>!
    var reducer: TestReducer!

    override func setUp() {
        super.setUp()
        reducer = TestReducer()
        store = Store(reducer: reducer.handleAction, state: TestAppState())
    }

    /**
     It does not strongly capture an observer
     */
    #if swift(>=4.1)
    func testDoesNotCaptureStrongly() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        var subscriber: TestSubscriber? = TestSubscriber()

        store.subscribe(subscriber!)
        XCTAssertEqual(store.subscriptions.compactMap({ $0.subscriber }).count, 1)

        subscriber = nil
        XCTAssertEqual(store.subscriptions.compactMap({ $0.subscriber }).count, 0)
    }
    #else
    func testDoesNotCaptureStrongly() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        var subscriber: TestSubscriber? = TestSubscriber()

        store.subscribe(subscriber!)
        XCTAssertEqual(store.subscriptions.flatMap({ $0.subscriber }).count, 1)

        subscriber = nil
        XCTAssertEqual(store.subscriptions.flatMap({ $0.subscriber }).count, 0)
    }
    #endif

    /**
     it removes deferenced subscribers before notifying state changes
     */
    func testRemoveSubscribers() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
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

    /**
     it replaces the subscription of an existing subscriber with the new one.
     */
    func testDuplicateSubscription() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = TestSubscriber()

        // Initial subscription.
        store.subscribe(subscriber)
        // Subsequent subscription that skips repeated updates.
        store.subscribe(subscriber) { $0.skipRepeats { $0.testValue == $1.testValue } }

        // One initial state update for every subscription.
        XCTAssertEqual(subscriber.receivedStates.count, 2)

        store.dispatch(SetValueAction(3))
        store.dispatch(SetValueAction(3))
        store.dispatch(SetValueAction(3))
        store.dispatch(SetValueAction(3))

        // Only a single further state update, since latest subscription skips repeated values.
        XCTAssertEqual(subscriber.receivedStates.count, 3)
    }
    /**
     it dispatches initial value upon subscription
     */
    func testDispatchInitialValue() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = TestSubscriber()

        store.subscribe(subscriber)
        store.dispatch(SetValueAction(3))

        XCTAssertEqual(subscriber.receivedStates.last?.testValue, 3)
    }

    /**
     it allows dispatching from within an observer
     */
    func testAllowDispatchWithinObserver() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = DispatchingSubscriber(store: store)

        store.subscribe(subscriber)
        store.dispatch(SetValueAction(2))

        XCTAssertEqual(store.state.testValue, 5)
    }

    /**
     it does not dispatch value after subscriber unsubscribes
     */
    func testDontDispatchToUnsubscribers() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = TestSubscriber()

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
        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 4].testValue, 5)
        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 3].testValue, 10)
        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 2].testValue, 25)
        XCTAssertEqual(subscriber.receivedStates[subscriber.receivedStates.count - 1].testValue, 20)
    }

    /**
     it ignores identical subscribers
     */
    func testIgnoreIdenticalSubscribers() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = TestSubscriber()

        store.subscribe(subscriber)
        store.subscribe(subscriber)

        XCTAssertEqual(store.subscriptions.count, 1)
    }

    /**
     it ignores identical subscribers that provide substate selectors
     */
    func testIgnoreIdenticalSubstateSubscribers() {
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = TestSubscriber()

        store.subscribe(subscriber) { $0 }
        store.subscribe(subscriber) { $0 }

        XCTAssertEqual(store.subscriptions.count, 1)
    }

    func testNewStateModifyingSubscriptionsDoesNotDiscardNewSubscription() {
        // This was built as a failing test due to a bug introduced by #325
        // The bug occured by adding a subscriber during `newState`
        // The bug was caused by creating a copy of `subscriptions` before calling
        // `newState`, and then assigning that copy back to `subscriptions`, losing
        // the mutation that occured during `newState`

        store = Store(reducer: reducer.handleAction, state: TestAppState())

        let subscriber2 = BlockSubscriber<TestAppState> { _ in
            self.store.dispatch(SetValueAction(2))
        }

        let subscriber1 = BlockSubscriber<TestAppState> { [unowned self] state in
            if state.testValue == 1 {
                self.store.subscribe(subscriber2) {
                    $0.skip(when: { _, _ in return true })
                }
            }
        }

        store.subscribe(subscriber1) {
            $0.only(when: { _, new in new.testValue.map { $0 == 1 } ?? false })
        }

        store.dispatch(SetValueAction(1))

        XCTAssertTrue(store.subscriptions.contains(where: {
            guard let subscriber = $0.subscriber else {
                XCTFail("expecting non-nil subscriber")
                return false
            }
            return subscriber === subscriber1
        }))
        XCTAssertTrue(store.subscriptions.contains(where: {
            guard let subscriber = $0.subscriber else {
                XCTFail("expecting non-nil subscriber")
                return false
            }
            return subscriber === subscriber2
        }))

        // Have a subscriber (#1)
        // #1 adds sub #2 in newState
        // #1 dispatches in newState
        // Test that store.subscribers == [#1, #2] // this should fail
    }
}

// MARK: Retain Cycle Detection

private struct TracerAction: Action { }

private class TestSubscriptionBox<S>: SubscriptionBox<S> {
    override init<T>(
        originalSubscription: Subscription<S>,
        transformedSubscription: Subscription<T>?,
        subscriber: AnyStoreSubscriber
        ) {
        super.init(originalSubscription: originalSubscription,
                   transformedSubscription: transformedSubscription,
                   subscriber: subscriber)
    }

    var didDeinit: (() -> Void)?
    deinit {
        didDeinit?()
    }
}

private class TestStore<State: StateType>: Store<State> {
    override func subscriptionBox<T>(
        originalSubscription: Subscription<State>,
        transformedSubscription: Subscription<T>?,
        subscriber: AnyStoreSubscriber) -> SubscriptionBox<State> {
        return TestSubscriptionBox(
            originalSubscription: originalSubscription,
            transformedSubscription: transformedSubscription,
            subscriber: subscriber
        )
    }
}

extension StoreSubscriptionTests {

    func testRetainCycle_OriginalSubscription() {

        var didDeinit = false

        autoreleasepool {

            store = TestStore(reducer: reducer.handleAction, state: TestAppState())
            let subscriber: TestSubscriber = TestSubscriber()

            // Preconditions
            XCTAssertEqual(subscriber.receivedStates.count, 0)
            XCTAssertEqual(store.subscriptions.count, 0)

            autoreleasepool {

                store.subscribe(subscriber)
                XCTAssertEqual(subscriber.receivedStates.count, 1)
                let subscriptionBox = store.subscriptions.first! as! TestSubscriptionBox<TestAppState>
                subscriptionBox.didDeinit = { didDeinit = true }

                store.dispatch(TracerAction())
                XCTAssertEqual(subscriber.receivedStates.count, 2)
                store.unsubscribe(subscriber)
            }

            XCTAssertEqual(store.subscriptions.count, 0)
            store.dispatch(TracerAction())
            XCTAssertEqual(subscriber.receivedStates.count, 2)

            store = nil
        }

        XCTAssertTrue(didDeinit)
    }

    func testRetainCycle_TransformedSubscription() {

        var didDeinit = false

        autoreleasepool {

            store = TestStore(reducer: reducer.handleAction, state: TestAppState(), automaticallySkipsRepeats: false)
            let subscriber = TestStoreSubscriber<Int?>()

            // Preconditions
            XCTAssertEqual(subscriber.receivedStates.count, 0)
            XCTAssertEqual(store.subscriptions.count, 0)

            autoreleasepool {

                store.subscribe(subscriber, transform: {
                    $0.select({ $0.testValue })
                })
                XCTAssertEqual(subscriber.receivedStates.count, 1)
                let subscriptionBox = store.subscriptions.first! as! TestSubscriptionBox<TestAppState>
                subscriptionBox.didDeinit = { didDeinit = true }

                store.dispatch(TracerAction())
                XCTAssertEqual(subscriber.receivedStates.count, 2)
                store.unsubscribe(subscriber)
            }

            XCTAssertEqual(store.subscriptions.count, 0)
            store.dispatch(TracerAction())
            XCTAssertEqual(subscriber.receivedStates.count, 2)

            store = nil
        }

        XCTAssertTrue(didDeinit)
    }
}
