//
//  IncompleteSubscriptionTests.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-05.
//  Copyright © 2019 ReSwift Community. All rights reserved.
//

import XCTest
import ReSwift

class IncompleteSubscriptionTests: XCTestCase {

    func testPassesOnRootState() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState(testValue: "Initial")
        let store = Store(reducer: reducer.handleAction, state: state, middleware: [])
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscription()
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(SetValueStringAction("New"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "New")
    }

    func testPassesOnRootStateChange() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState(testValue: "Initial")
        let store = Store(reducer: reducer.handleAction, state: state, middleware: [])
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscription()
            .subscribe(subscriber)
        store.dispatch(SetValueStringAction("New"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "New")
    }

    func testPassesOnSelectedSubstate_AutomaticallySkipsRepeats() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState(testValue: "Initial")
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            middleware: [],
            automaticallySkipsRepeats: true)
        let subscriber = TestFilteredSubscriber<String>()

        store.subscription()
            .select { $0.testValue }
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testPassesOnSelectedSubstate_NotAutomaticallySkippingRepeats() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState(testValue: "Initial")
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            middleware: [],
            automaticallySkipsRepeats: false)
        let subscriber = TestFilteredSubscriber<String>()

        store.subscription()
            .select { $0.testValue }
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testPassesOnSelectedSubstate_NotAutomaticallyButManuallySkippingRepeats() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState(testValue: "Initial")
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            middleware: [],
            automaticallySkipsRepeats: false)
        let subscriber = TestFilteredSubscriber<String>()

        store.subscription()
            .select { $0.testValue }
            .skipRepeats()
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }
}
