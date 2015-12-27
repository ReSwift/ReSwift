//
//  StoreMiddlewareTests.swift
//  SwiftFlow
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftFlow

let firstMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            if action.type == SetValueStringAction.type {
                var modifiedAction = SetValueStringAction(action)
                modifiedAction.value = modifiedAction.value + " First Middleware"
                return next(modifiedAction.toAction())
            } else {
                return next(action)
            }
        }
    }
}

let secondMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            if action.type == SetValueStringAction.type {
                var modifiedAction = SetValueStringAction(action)
                modifiedAction.value = modifiedAction.value + " Second Middleware"
                return next(modifiedAction.toAction())
            } else {
                return next(action)
            }
        }
    }
}

let dispatchingMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            if action.type == SetValueAction.type {
                let valueAction = SetValueAction(action)
                dispatch(SetValueStringAction("\(valueAction.value)").toAction())

                return "Converted Action Successfully"
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
                let store = MainStore(reducer: reducer, appState: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware])

                let subscriber = TestStoreSubscriber<TestStringAppState>()
                store.subscribe(subscriber)

                let action = SetValueStringAction("OK")
                store.dispatch(action)

                expect((store.appState as! TestStringAppState).testValue).to(
                    equal("OK First Middleware Second Middleware"))
            }

            it("can dispatch actions") {
                let reducer = TestValueStringReducer()
                let store = MainStore(reducer: reducer, appState: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

                let subscriber = TestStoreSubscriber<TestStringAppState>()
                store.subscribe(subscriber)

                let action = SetValueAction(10)
                store.dispatch(action)

                expect((store.appState as! TestStringAppState).testValue).to(
                    equal("10 First Middleware Second Middleware"))
            }

            it("can change the return value of the dispatch function") {
                let reducer = TestValueStringReducer()
                let store = MainStore(reducer: reducer, appState: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

                let action = SetValueAction(10)
                let returnValue = store.dispatch(action) as? String

                expect(returnValue).to(equal("Converted Action Successfully"))
            }

        }
    }

}
