//
//  ObservableCombinedReducerTests.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

class MockObservableReducer: ObservableReducer {

    var calledWithAction: [Action] = []

    func handleAction(action: Action, state: CounterState) -> CounterState {
        calledWithAction.append(action)

        return state
    }

}

class IncreaseByOneObservableReducer: ObservableReducer {
    func handleAction(action: Action, state: CounterState) -> CounterState {
        return CounterState(count: state.count + 1)
    }
}

class IncreaseByTwoObservableReducer: ObservableReducer {
    func handleAction(action: Action, state: CounterState) -> CounterState {
        return CounterState(count: state.count + 2)
    }
}

class ObservableCombinedReducerTest: XCTestCase {

    /**
     it calls each of the reducers with the given action exactly once
     */
    func testCallsReducersOnce() {
        let mockReducer1 = MockObservableReducer()
        let mockReducer2 = MockObservableReducer()

        let combinedReducer = ObservableCombinedReducer(mockReducer1, mockReducer2)

        _ = combinedReducer._handleAction(
            action: StandardAction(type: emptyAction),
            state: CounterState())

        XCTAssertEqual(mockReducer1.calledWithAction.count, 1)
        XCTAssertEqual(mockReducer2.calledWithAction.count, 1)
        XCTAssertEqual((mockReducer1.calledWithAction.first as? StandardAction)?.type, emptyAction)
        XCTAssertEqual((mockReducer2.calledWithAction.first as? StandardAction)?.type, emptyAction)
    }

    /**
     it combines the results from each individual reducer correctly
     */
    func testCombinesReducerResults() {
        let increaseByOneReducer = IncreaseByOneObservableReducer()
        let increaseByTwoReducer = IncreaseByTwoObservableReducer()

        let combinedReducer = ObservableCombinedReducer(increaseByOneReducer, increaseByTwoReducer)

        let newState = combinedReducer._handleAction(
            action: StandardAction(type: emptyAction),
            state: CounterState()) as? CounterState

        XCTAssertEqual(newState?.count, 3)
    }
}
