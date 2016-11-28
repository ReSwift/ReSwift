//
//  ObservableStoreMiddlewareTests.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

// swiftlint:disable function_body_length
class ObservableStoreMiddlewareTests: XCTestCase {

    /**
     it can decorate dispatch function
     */
    func testDecorateDispatch() {
        let store = ObservableStore(reducer: TestValueStringReducer(),
            stateType: TestStringAppState.self,
            observable: ObservableProperty(TestStringAppState()),
            middleware: [firstMiddleware, secondMiddleware])

        let subscriber = ObservableTestStoreSubscriber<TestStringAppState>()
        store.observable.subscribe(subscriber.subscription)

        let action = SetValueStringAction("OK")
        store.dispatch(action)

        XCTAssertEqual(store.observable.value.testValue, "OK First Middleware Second Middleware")
    }

    /**
     it can dispatch actions
     */
    func testCanDispatch() {
        let store = ObservableStore(reducer: TestValueStringReducer(),
            stateType: TestStringAppState.self,
            observable: ObservableProperty(TestStringAppState()),
            middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

        let subscriber = ObservableTestStoreSubscriber<TestStringAppState>()
        store.observable.subscribe(subscriber.subscription)

        let action = SetValueAction(10)
        store.dispatch(action)

        XCTAssertEqual(store.observable.value.testValue, "10 First Middleware Second Middleware")
    }

    /**
     it can change the return value of the dispatch function
     */
    func testCanChangeReturnValue() {
        let store = ObservableStore(reducer: TestValueStringReducer(),
            stateType: TestStringAppState.self,
            observable: ObservableProperty(TestStringAppState()),
            middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

        let action = SetValueAction(10)
        let returnValue = store.dispatch(action) as? String

        XCTAssertEqual(returnValue, "Converted Action Successfully")
    }

    /**
     it middleware can access the store's state
     */
    func testMiddlewareCanAccessState() {
        let property = ObservableProperty(TestStringAppState(testValue: "OK"))
        let store = ObservableStore(reducer: TestValueStringReducer(),
                                    stateType: TestStringAppState.self,
                                    observable: property,
                                    middleware: [stateAccessingMiddleware])

        store.dispatch(SetValueStringAction("Action That Won't Go Through"))

        XCTAssertEqual(store.observable.value.testValue, "Not OK")
    }
}
