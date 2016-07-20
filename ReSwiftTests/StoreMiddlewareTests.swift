//
//  StoreMiddlewareTests.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import XCTest
@testable import ReSwift

let firstMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            if var action = action as? SetValueStringAction {
                action.value = action.value + " First Middleware"
                return next(action)
            } else {
                return next(action)
            }
        }
    }
}

let secondMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            if var action = action as? SetValueStringAction {
                action.value = action.value + " Second Middleware"
                return next(action)
            } else {
                return next(action)
            }
        }
    }
}

let dispatchingMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            if var action = action as? SetValueAction {
                _ = dispatch?(SetValueStringAction("\(action.value)"))

                return "Converted Action Successfully"
            }

            return next(action)
        }
    }
}

let stateAccessingMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            let appState = getState() as? TestStringAppState,
                stringAction = action as? SetValueStringAction

            // avoid endless recursion by checking if we've dispatched exactly this action
            if appState?.testValue == "OK" && stringAction?.value != "Not OK" {
                // dispatch a new action
                _ = dispatch?(SetValueStringAction("Not OK"))

                // and swallow the current one
                return next(StandardAction(type: "No-Op-Action"))
            }

            return next(action)
        }
    }
}

// swiftlint:disable function_body_length
class StoreMiddlewareSpecs: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }


    func testDecorateDispatch() {
        // can decorate dispatch function
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

    func testCanDispatchActions() {
        // can dispatch actions
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

    func testCanChangeReturnValue() {
        // can change the return value of the dispatch function
        let reducer = TestValueStringReducer()
        let store = Store<TestStringAppState>(reducer: reducer,
            state: TestStringAppState(),
            middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

        let action = SetValueAction(10)
        let returnValue = store.dispatch(action) as? String

        XCTAssertEqual(returnValue, "Converted Action Successfully")
    }

    func testMiddlewareCanAccessStoresState() {
        // middleware can access the store's state
        let reducer = TestValueStringReducer()
        var state = TestStringAppState()
        state.testValue = "OK"

        let store = Store<TestStringAppState>(reducer: reducer, state: state,
            middleware: [stateAccessingMiddleware])

        store.dispatch(SetValueStringAction("Action That Won't Go Through"))

        XCTAssertEqual(store.state.testValue, "Not OK")
    }
}
