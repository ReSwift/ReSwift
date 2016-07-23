//
//  StoreTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import XCTest
import ReSwift

class StoreTests: XCTestCase {

    /**
     it dispatches an Init action when it doesn't receive an initial state
     */
    func testInit() {
        let reducer = MockReducer()
        let _ = Store<CounterState>(reducer: reducer, state: nil)

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
                reducer: reducer,
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
        reducer: AnyReducer,
        state: State?,
        deInitAction: () -> Void) {
            self.init(reducer: reducer, state: state, middleware: [])
            self.deInitAction = deInitAction
    }

    required init(reducer: AnyReducer, state: State?, middleware: [Middleware]) {
        super.init(reducer: reducer, state: state, middleware: middleware)
    }
}
