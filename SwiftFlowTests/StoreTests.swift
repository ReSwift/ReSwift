//
//  SwiftFlowTests.swift
//  SwiftFlowTests
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SwiftFlow

// swiftlint:disable function_body_length
class StoreSpecs: QuickSpec {


    override func spec() {

        describe("#subscribe") {

            var store: Store!
            var reducer: TestReducer!

            beforeEach {
                reducer = TestReducer()
                store = MainStore(reducer: reducer, appState: TestAppState())
            }

            it("dispatches initial value upon subscription") {
                store = MainStore(reducer: reducer, appState: TestAppState())
                let subscriber = TestStoreSubscriber<TestAppState>()

                store.subscribe(subscriber)

                waitUntil(timeout: 2.0) { fulfill in
                    store.dispatch(SetValueAction(3)) { newState in
                        if subscriber.receivedStates.last?.testValue == 3 {
                            fulfill()
                        }
                    }
                }
            }

            it("does not dispatch value after subscriber unsubscribes") {
                store = MainStore(reducer: reducer, appState: TestAppState())
                let subscriber = TestStoreSubscriber<TestAppState>()

                store.dispatch(SetValueAction(5))
                store.subscribe(subscriber)
                store.dispatch(SetValueAction(10))

                // Let Run Loop Run so that dispatched actions can be performed
                NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode,
                    beforeDate: NSDate.distantFuture())

                store.unsubscribe(subscriber)
                // Following value is missed due to not being subscribed:
                store.dispatch(SetValueAction(15))
                store.dispatch(SetValueAction(25))

                // Let Run Loop Run so that dispatched actions can be performed
                NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode,
                    beforeDate: NSDate.distantFuture())

                store.subscribe(subscriber)

                waitUntil(timeout: 2.0) { fulfill in
                    store.dispatch(SetValueAction(20)) { newState in
                        if subscriber.receivedStates[subscriber.receivedStates.count - 1]
                            .testValue == 20
                            && subscriber.receivedStates[subscriber.receivedStates.count - 2]
                                .testValue == 25
                            && subscriber.receivedStates[subscriber.receivedStates.count - 3]
                                .testValue == 10 {
                                    fulfill()
                        }
                    }
                }
            }

        }

    }

}
// swiftlint:enable function_body_length
