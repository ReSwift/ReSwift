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
        let state = TestStringAppState()
        let store = Store(reducer: reducer.handleAction, state: state, middleware: [])
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscription()
            .subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testPassesOnSelectedSubstate() {
        let reducer = TestReducer()
        let store = Store(reducer: reducer.handleAction, state: TestAppState())
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscription()
            .select { $0.testValue }
            .subscribe(subscriber)

        store.dispatch(SetValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(SetValueAction(nil))

        #if swift(>=4.1)
        XCTAssertEqual(subscriber.receivedValue, .some(.none))
        #else
        XCTAssertEqual(subscriber.receivedValue, nil)
        #endif
    }
}
