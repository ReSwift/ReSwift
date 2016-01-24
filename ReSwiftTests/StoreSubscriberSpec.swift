//
//  StoreSubscriberSpec.swift
//  ReSwift
//
//  Created by Benji Encz on 1/23/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Quick
import Nimble
@testable import ReSwift

// swiftlint:disable function_body_length
class FilteredStoreSpec: QuickSpec {

    override func spec() {

        describe("#subscribe") {

            var store: Store<TestAppState>!
            var reducer: TestReducer!

            beforeEach {
                reducer = TestReducer()
                store = Store(reducer: reducer, state: TestAppState())
            }

            it("dispatches initial value upon subscription") {
                store = Store(reducer: reducer, state: TestAppState())
                let subscriber = TestFilteredSubscriber()

                store.subscribe(subscriber) {
                    $0.testValue
                }

                store.dispatch(SetValueAction(3))

                expect(subscriber.receivedValue).to(equal(3))
            }
        }

    }

}

class TestFilteredSubscriber: StoreSubscriber {
    var receivedValue: Int?

    func newState(state: Int?) {
        receivedValue = state
    }

}
