//
//  BlockSubscriberTests.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-05.
//  Copyright © 2019 ReSwift. All rights reserved.
//

import XCTest
@testable import ReSwift

class BlockSubscriberTests: XCTestCase {

    func testBlock() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            middleware: [],
            automaticallySkipsRepeats: true)

        var receivedValue: TestStringAppState? = nil
        var newStateCallCount = 0
        let subscriber = BlockSubscriber<TestStringAppState> {
            receivedValue = $0
            newStateCallCount += 1
        }

        store.subscribe(subscriber)

        XCTAssertEqual(receivedValue?.testValue, "Initial")
        XCTAssertEqual(newStateCallCount, 1)

        store.dispatch(SetValueStringAction("Initial"))

        XCTAssertEqual(receivedValue?.testValue, "Initial")
        XCTAssertEqual(newStateCallCount, 1)

        store.dispatch(SetValueStringAction("New"))

        XCTAssertEqual(receivedValue?.testValue, "New")
        XCTAssertEqual(newStateCallCount, 2)
    }

}
