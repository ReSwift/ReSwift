//
//  StoreMiddlewareTests.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import Quick
import Nimble
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
                dispatch(SetValueStringAction("\(action.value)"))

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
                dispatch(SetValueStringAction("Not OK"))

                // and swallow the current one
                return next(StandardAction("No-Op-Action"))
            }

            return next(action)
        }
    }
}

// swiftlint:disable function_body_length
class StoreMiddlewareSpecs: QuickSpec {


    override func spec() {

        describe("middleware") {

            it("can decorate dispatch function") {
                let reducer = TestValueStringReducer()
                let store = MainStore<TestStringAppState>(reducer: reducer,
                    state: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware])

                let subscriber = TestStoreSubscriber<TestStringAppState>()
                store.subscribe(subscriber)

                let action = SetValueStringAction("OK")
                store.dispatch(action)

                expect(store.state.testValue).to(
                    equal("OK First Middleware Second Middleware"))
            }

            it("can dispatch actions") {
                let reducer = TestValueStringReducer()
                let store = MainStore<TestStringAppState>(reducer: reducer,
                    state: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

                let subscriber = TestStoreSubscriber<TestStringAppState>()
                store.subscribe(subscriber)

                let action = SetValueAction(10)
                store.dispatch(action)

                expect(store.state.testValue).to(
                    equal("10 First Middleware Second Middleware"))
            }

            it("can change the return value of the dispatch function") {
                let reducer = TestValueStringReducer()
                let store = MainStore<TestStringAppState>(reducer: reducer,
                    state: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

                let action = SetValueAction(10)
                let returnValue = store.dispatch(action) as? String

                expect(returnValue).to(equal("Converted Action Successfully"))
            }

            it("middleware can access the store's state") {
                let reducer = TestValueStringReducer()
                var state = TestStringAppState()
                state.testValue = "OK"

                let store = MainStore<TestStringAppState>(reducer: reducer, state: state,
                    middleware: [stateAccessingMiddleware])

                store.dispatch(SetValueStringAction("Action That Won't Go Through"))

                expect(store.state.testValue).to(equal("Not OK"))
            }

        }
    }

}
