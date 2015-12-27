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
                store.dispatch(SetValueAction(3))

                expect(subscriber.receivedStates.last?.testValue).to(equal(3))
            }

            it("does not dispatch value after subscriber unsubscribes") {
                store = MainStore(reducer: reducer, appState: TestAppState())
                let subscriber = TestStoreSubscriber<TestAppState>()

                store.dispatch(SetValueAction(5))
                store.subscribe(subscriber)
                store.dispatch(SetValueAction(10))

                store.unsubscribe(subscriber)
                // Following value is missed due to not being subscribed:
                store.dispatch(SetValueAction(15))
                store.dispatch(SetValueAction(25))

                store.subscribe(subscriber)

                store.dispatch(SetValueAction(20))

                expect(subscriber.receivedStates.count).to(equal(4))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 4]
                    .testValue).to(equal(5))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 3]
                    .testValue).to(equal(10))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 2]
                    .testValue).to(equal(25))

                expect(subscriber.receivedStates[subscriber.receivedStates.count - 1]
                    .testValue).to(equal(20))
            }

        }

        describe("#dispatch") {

            var store: Store!
            var reducer: TestReducer!

            beforeEach {
                reducer = TestReducer()
                store = MainStore(reducer: reducer, appState: TestAppState())
            }

            it("returns the dispatched action") {
                let action = SetValueAction(10)
                let returnValue = SetValueAction(store.dispatch(action) as! Action)

                expect(returnValue.value).to(equal(action.value))
            }

        }

    }

}
// swiftlint:enable function_body_length
