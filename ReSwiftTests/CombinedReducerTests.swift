//
//  CombinedReducerTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/20/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

class MockReducer: Reducer {

    var calledWithAction: [Action] = []

    func handleAction(action: Action, state: CounterState?) -> CounterState {
        calledWithAction.append(action)

        return state ?? CounterState()
    }

}

class IncreaseByOneReducer: Reducer {
    func handleAction(action: Action, state: CounterState?) -> CounterState {
        var state = state ?? CounterState()

        state.count = state.count + 1

        return state
    }
}

class IncreaseByTwoReducer: Reducer {
    func handleAction(action: Action, state: CounterState?) -> CounterState {
        var state = state ?? CounterState()

        state.count = state.count + 2

        return state
    }
}

struct CounterState: StateType {
    var count: Int = 0
}

let emptyAction = "EMPTY_ACTION"


class CombinedReducerTest: XCTestCase {

    /**
     it calls each of the reducers with the given action exactly once
     */
    func testCallsReducersOnce() {
        let mockReducer1 = MockReducer()
        let mockReducer2 = MockReducer()

        let combinedReducer = CombinedReducer([mockReducer1, mockReducer2])

        #if swift(>=3)
            _ = combinedReducer._handleAction(
                action: StandardAction(type: emptyAction),
                state: CounterState())
        #else
            combinedReducer._handleAction(StandardAction(type: emptyAction), state: CounterState())
        #endif

        XCTAssertEqual(mockReducer1.calledWithAction.count, 1)
        XCTAssertEqual(mockReducer2.calledWithAction.count, 1)
        XCTAssertEqual((mockReducer1.calledWithAction[0] as! StandardAction).type, emptyAction)
        XCTAssertEqual((mockReducer2.calledWithAction[0] as! StandardAction).type, emptyAction)
    }

    /**
     it combines the results from each individual reducer correctly
     */
    func testCombinesReducerResults() {
        let increaseByOneReducer = IncreaseByOneReducer()
        let increaseByTwoReducer = IncreaseByTwoReducer()

        let combinedReducer = CombinedReducer([increaseByOneReducer, increaseByTwoReducer])
        #if swift(>=3)
            let newState = combinedReducer._handleAction(
                action: StandardAction(type: emptyAction),
                state: CounterState()) as? CounterState
        #else
            let newState = combinedReducer._handleAction(
                StandardAction(type: emptyAction),
                state: CounterState()) as? CounterState
        #endif

        XCTAssertEqual(newState?.count, 3)
    }
}
