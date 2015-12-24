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

            var theAction = SetValueStringAction(action.toAction())
            theAction.value = theAction.value + " First Middleware"
            return next(theAction.toAction())
        }
    }
}

let secondMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            var theAction = SetValueStringAction(action.toAction())
            theAction.value = theAction.value + " Second Middleware"
            return next(theAction.toAction())
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

                waitUntil(timeout: 2.0) { fulfill in
                    store.dispatch(action) { newState in
                        if subscriber.receivedStates.last?.testValue
                                == "OK First Middleware Second Middleware" {
                                    fulfill()
                        }
                    }
                }

            }

        }
    }

}
