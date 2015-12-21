//
//  CombinedReducerTests.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 12/20/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftFlow

class MockReducer: Reducer {

    var calledWithAction: [Action] = []

    func handleAction(state: StateType, action: Action) -> StateType {
        calledWithAction.append(action)

        return state
    }

}

class IncreaseByOneReducer: Reducer {
    func handleAction(state: CounterState, action: Action) -> CounterState {
        var newState = state
        newState.count = state.count + 1

        return newState
    }
}

class IncreaseByTwoReducer: Reducer {
    func handleAction(state: CounterState, action: Action) -> CounterState {
        var newState = state
        newState.count = state.count + 2

        return newState
    }
}

struct CounterState: StateType {
    var count: Int = 0
}

let emptyAction = "EMPTY_ACTION"

// swiftlint:disable function_body_length
class CombinedReducerSpecs: QuickSpec {

    override func spec() {
        describe("Combined Reducer") {

            it("calls each of the reducers with the given action exactly once") {
                let mockReducer1 = MockReducer()
                let mockReducer2 = MockReducer()

                let combinedReducer = CombinedReducer([mockReducer1, mockReducer2])

                combinedReducer._handleAction(CounterState(), action: Action(emptyAction))

                expect(mockReducer1.calledWithAction).to(haveCount(1))
                expect(mockReducer2.calledWithAction).to(haveCount(1))
                expect(mockReducer1.calledWithAction[0].type).to(equal(emptyAction))
                expect(mockReducer2.calledWithAction[0].type).to(equal(emptyAction))
            }

            it("combines the results from each individual reducer correctly") {
                let increaseByOneReducer = IncreaseByOneReducer()
                let increaseByTwoReducer = IncreaseByTwoReducer()

                let combinedReducer = CombinedReducer([increaseByOneReducer, increaseByTwoReducer])
                let newState = combinedReducer._handleAction(CounterState(),
                    action: Action(emptyAction)) as? CounterState

                expect(newState?.count).to(equal(3))
            }

        }
    }

}
// swiftlint:enable function_body_length
