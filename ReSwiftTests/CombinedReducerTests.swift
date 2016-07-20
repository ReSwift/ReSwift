//
//  CombinedReducerTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/20/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import XCTest
@testable import ReSwift

class MockReducer: Reducer {

    var calledWithAction: [Action] = []

    func handleAction(_ action: Action, state: CounterState?) -> CounterState {
        calledWithAction.append(action)

        return state ?? CounterState()
    }

}

class IncreaseByOneReducer: Reducer {
    func handleAction(_ action: Action, state: CounterState?) -> CounterState {
        var state = state ?? CounterState()

        state.count = state.count + 1

        return state
    }
}

class IncreaseByTwoReducer: Reducer {
    func handleAction(_ action: Action, state: CounterState?) -> CounterState {
        var state = state ?? CounterState()

        state.count = state.count + 2

        return state
    }
}

struct CounterState: StateType {
    var count: Int = 0
}

let emptyAction = "EMPTY_ACTION"

// swiftlint:disable function_body_length
class CombinedReducerSpecs: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCombinedReducer() {
        // calls each of the reducers with the given action exactly once
        let mockReducer1 = MockReducer()
        let mockReducer2 = MockReducer()

        let combinedReducer = CombinedReducer([mockReducer1, mockReducer2])

        _ = combinedReducer._handleAction(
            StandardAction(type: emptyAction),
            state: CounterState()
        )

        XCTAssertEqual(mockReducer1.calledWithAction.count, 1)
        XCTAssertEqual(mockReducer2.calledWithAction.count, 1)
        XCTAssertEqual((mockReducer1.calledWithAction[0] as! StandardAction).type, emptyAction)
        XCTAssertEqual((mockReducer2.calledWithAction[0] as! StandardAction).type, emptyAction)
    }

  func testCombinedReducerIndividual() {
        // combines the results from each individual reducer correctly
        let increaseByOneReducer = IncreaseByOneReducer()
        let increaseByTwoReducer = IncreaseByTwoReducer()

        let combinedReducer = CombinedReducer([increaseByOneReducer, increaseByTwoReducer])
        let newState = combinedReducer._handleAction(StandardAction(type: emptyAction),
            state: CounterState()) as? CounterState

        XCTAssertEqual(newState?.count, 3)
    }

}
// swiftlint:enable function_body_length
