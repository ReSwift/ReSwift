//
//  StoreMiddlewareTests.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

// swiftlint:disable function_body_length
class StoreMiddlewareTests: XCTestCase {

    /**
     it can decorate dispatch function
     */
    func testDecorateDispatch() {
        let reducer = TestValueStringReducer()
        let store = Store<TestStringAppState>(reducer: reducer,
            state: TestStringAppState(),
            middleware: [firstMiddleware, secondMiddleware])

        let subscriber = TestStoreSubscriber<TestStringAppState>()
        store.subscribe(subscriber)

        let action = SetValueStringAction("OK")
        store.dispatch(action)

        XCTAssertEqual(store.state.testValue, "OK First Middleware Second Middleware")
    }

    /**
     it can dispatch actions
     */
    func testCanDispatch() {
        let reducer = TestValueStringReducer()
        let store = Store<TestStringAppState>(reducer: reducer,
            state: TestStringAppState(),
            middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

        let subscriber = TestStoreSubscriber<TestStringAppState>()
        store.subscribe(subscriber)

        let action = SetValueAction(10)
        store.dispatch(action)

        XCTAssertEqual(store.state.testValue, "10 First Middleware Second Middleware")
    }

    /**
     it can change the return value of the dispatch function
     */
    func testCanChangeReturnValue() {
        let reducer = TestValueStringReducer()
        let store = Store<TestStringAppState>(reducer: reducer,
            state: TestStringAppState(),
            middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

        let action = SetValueAction(10)
        let returnValue = store.dispatch(action) as? String

        XCTAssertEqual(returnValue, "Converted Action Successfully")
    }

    /**
     it middleware can access the store's state
     */
    func testMiddlewareCanAccessState() {
        let reducer = TestValueStringReducer()
        var state = TestStringAppState()
        state.testValue = "OK"

        let store = Store<TestStringAppState>(reducer: reducer, state: state,
            middleware: [stateAccessingMiddleware])

        store.dispatch(SetValueStringAction("Action That Won't Go Through"))

        XCTAssertEqual(store.state.testValue, "Not OK")
    }
}
