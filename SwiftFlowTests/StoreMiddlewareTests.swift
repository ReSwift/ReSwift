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
            }

            return next(action)
        }
    }
}

// swiftlint:disable function_body_length
class StoreMiddlewareSpecs: QuickSpec {


    override func spec() {

        describe("middleware") {

            it("can be initialized with middleware which decorates dispatch function") {
                let reducer = TestValueStringReducer()
                let store = MainStore(reducer: reducer, appState: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware])

                let subscriber = TestStoreSubscriber<TestStringAppState>()
                store.subscribe(subscriber)

                let action = SetValueStringAction("OK")
                store.dispatch(action)

                expect((store.appState as! TestStringAppState).testValue).toEventually(
                    equal("OK First Middleware Second Middleware"), timeout: 2.0)
            }

            it("middleware can dispatch actions") {
                let reducer = TestValueStringReducer()
                let store = MainStore(reducer: reducer, appState: TestStringAppState(),
                    middleware: [firstMiddleware, secondMiddleware, dispatchingMiddleware])

                let subscriber = TestStoreSubscriber<TestStringAppState>()
                store.subscribe(subscriber)

                let action = SetValueAction(10)
                store.dispatch(action)

                expect((store.appState as! TestStringAppState).testValue).toEventually(
                    equal("10 First Middleware Second Middleware"), timeout: 2.0)
            }

        }
    }

}
