//
//  StoreMiddlewareTests.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

let firstMiddleware: Middleware<StateType> = { dispatch, getState in
    return { next in
        return { action in

            if var action = action as? SetValueStringAction {
                action.value += " First Middleware"
                return next(action)
            } else {
                return next(action)
            }
        }
    }
}

let secondMiddleware: Middleware<StateType> = { dispatch, getState in
    return { next in
        return { action in

            if var action = action as? SetValueStringAction {
                action.value += " Second Middleware"
                return next(action)
            } else {
                return next(action)
            }
        }
    }
}

let dispatchingMiddleware: Middleware<StateType> = { dispatch, getState in
    return { next in
        return { action in

            if var action = action as? SetValueAction {
                dispatch(SetValueStringAction("\(action.value)"))
            }

            return next(action)
        }
    }
}

let stateAccessingMiddleware: Middleware<TestStringAppState> = { dispatch, getState in
    return { next in
        return { action in

            let appState = getState(),
                stringAction = action as? SetValueStringAction

            // avoid endless recursion by checking if we've dispatched exactly this action
            if appState?.testValue == "OK" && stringAction?.value != "Not OK" {
                // dispatch a new action
                dispatch(SetValueStringAction("Not OK"))

                // and swallow the current one
                return next(StandardAction(type: "No-Op-Action"))
            }

            return next(action)
        }
    }
}

// swiftlint:disable function_body_length
class StoreMiddlewareTests: XCTestCase {

    /**
     it can decorate dispatch function
     */
    func testDecorateDispatch() {
        let reducer = TestValueStringReducer()
        let store = Store<TestStringAppState>(reducer: reducer.handleAction,
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
        let store = Store<TestStringAppState>(reducer: reducer.handleAction,
            state: TestStringAppState(),
            middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

        let subscriber = TestStoreSubscriber<TestStringAppState>()
        store.subscribe(subscriber)

        let action = SetValueAction(10)
        store.dispatch(action)

        XCTAssertEqual(store.state.testValue, "10 First Middleware Second Middleware")
    }

    /**
     it middleware can access the store's state
     */
    func testMiddlewareCanAccessState() {
        let reducer = TestValueStringReducer()
        var state = TestStringAppState()
        state.testValue = "OK"

        let store = Store<TestStringAppState>(reducer: reducer.handleAction, state: state,
            middleware: [stateAccessingMiddleware])

        store.dispatch(SetValueStringAction("Action That Won't Go Through"))

        XCTAssertEqual(store.state.testValue, "Not OK")
    }
}
