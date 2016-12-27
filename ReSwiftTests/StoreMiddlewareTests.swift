//
//  StoreMiddlewareTests.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

let firstMiddleware = Middleware().map { state, action in
    if let action = action as? SetValueStringAction {
        return SetValueStringAction(action.value + " First Middleware")
    }
    return action
}

let secondMiddleware = Middleware().map { state, action in
    if let action = action as? SetValueStringAction {
        return SetValueStringAction(action.value + " Second Middleware")
    }
    return action
}

let dispatchingMiddleware = Middleware().sideEffect { state, dispatch, action in
    if let action = action as? SetValueAction {
        dispatch(SetValueStringAction("\(action.value)"))
    }
}.filter { _, action in
    !(action is SetValueAction)
}

let stateAccessingMiddleware = Middleware().sideEffect { state, dispatch, action in
    if let action = action as? SetValueStringAction, let state = state() as? TestStringAppState {
        //Avoid endless recursion by checking if we've exactly this action
        if state.testValue == "OK" && action.value != "Not OK" {
            dispatch(SetValueStringAction("Not OK"))
        }
    }
}.filter { state, action in
    print("Swallowing action \(action)")
    return (action as? SetValueStringAction)?.value == "Not OK"
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
            middleware: firstMiddleware.concat(secondMiddleware))

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
            middleware: Middleware(firstMiddleware, secondMiddleware, dispatchingMiddleware))

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
            middleware: stateAccessingMiddleware)

        store.dispatch(SetValueStringAction("Action That Won't Go Through"))

        XCTAssertEqual(store.state.testValue, "Not OK")
    }

    /**
     it actions should be multiplied via the increase function
     */
    func testMiddlewareMultiplies() {
        let increaseByOneReducer: Reducer<CounterState> = { action, state in
            var state = state
            state?.count += 1
            return state
        }
        let multiplexingMiddleware = Middleware().increase { [$1, $1, $1] }.flatMap { $1 }
        let store = Store<CounterState>(reducer: increaseByOneReducer,
                          state: CounterState(),
                          middleware: multiplexingMiddleware)
        store.dispatch(SetValueStringAction("Meaningless Action"))
        XCTAssertEqual(store.state.count, 3)
    }
}
