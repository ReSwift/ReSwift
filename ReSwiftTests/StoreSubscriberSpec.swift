//
//  StoreSubscriberSpec.swift
//  ReSwift
//
//  Created by Benji Encz on 1/23/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import ReSwift

// swiftlint:disable function_body_length
class StoreSubsriberSpec: QuickSpec {

    override func spec() {

        var store: Store<TestAppState>!
        var reducer: TestReducer!

        describe("Substate Selection") {

            beforeEach {
                reducer = TestReducer()
                store = Store(reducer: reducer, state: TestAppState())
            }

            it("it allows subscribers to subselect a state") {
                let subscriber = TestSelectiveSubscriber()

                store.subscribe(subscriber)
                store.dispatch(SetValueAction(5))

                expect(subscriber.receivedValue).to(equal(5))
            }

        }

    }

}

class TestSelectiveSubscriber: StoreSubscriber {
    var receivedValue: Int?

    func newState(state: Int?) {
        receivedValue = state
    }

    func selectSubstate(state: TestAppState) -> Int? {
        return state.testValue
    }

}
