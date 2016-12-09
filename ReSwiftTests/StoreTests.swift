//
//  StoreTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import XCTest
@testable import ReSwift

class StoreTests: XCTestCase {

    /**
     it dispatches an Init action when it doesn't receive an initial state
     */
    func testInit() {
        let reducer = MockReducer()
        let _ = Store<CounterState>(reducer: reducer.handleAction, state: nil)

        XCTAssert(reducer.calledWithAction[0] is ReSwiftInit)
    }

    /**
     it deinitializes when no reference is held
     */
    func testDeinit() {
        var deInitCount = 0

        autoreleasepool {
            let reducer = TestReducer()
            let _ = DeInitStore(
                reducer: reducer.handleAction,
                state: TestAppState(),
                deInitAction: { deInitCount += 1 })
        }

        XCTAssertEqual(deInitCount, 1)
    }

}

// Used for deinitialization test
class DeInitStore<State: StateType>: Store<State> {
    var deInitAction: (() -> Void)?

    deinit {
        deInitAction?()
    }

    required convenience init(
        reducer: @escaping Reducer<State>,
        state: State?,
        deInitAction: (() -> Void)?) {
            self.init(reducer: reducer, state: state, middleware: [])
            self.deInitAction = deInitAction
    }

    required init(reducer: @escaping Reducer<State>, state: State?, middleware: [Middleware]) {
        super.init(reducer: reducer, state: state, middleware: middleware)
    }
}

struct CounterState: StateType {
    var count: Int = 0
}

class MockReducer {

    var calledWithAction: [Action] = []

    func handleAction(action: Action, state: CounterState?) -> CounterState {
        calledWithAction.append(action)

        return state ?? CounterState()
    }

}
