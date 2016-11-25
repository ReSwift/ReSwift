//
//  ObservableTypeHelperTests.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
/**
 @testable import for internal testing of `withObservableSpecificTypes`
 */
@testable import ReSwift

fileprivate struct AppState1: StateType {}
fileprivate struct AppState2: StateType {}

class ObservableTypeHelperTests: XCTestCase {

    /**
     it calls methods if the source type can be casted into the function signature type
     */
    func testSourceTypeCasting() {
        var called = false
        let reducerFunction: (Action, AppState1) -> AppState1 = { _, state in
            called = true

            return state
        }

        withObservableSpecificTypes(StandardAction(type: ""),
                                    state: AppState1(),
                                    function: reducerFunction)

        XCTAssertTrue(called)
    }

    /**
     it doesn't call if source type can't be casted to function signature type
     */
    func testDoesntCallIfCastFails() {
        var called = false
        let reducerFunction: (Action, AppState1) -> AppState1 = { _, state in
            called = true

            return state
        }

        withObservableSpecificTypes(StandardAction(type: ""),
                                    state: AppState2(),
                                    function: reducerFunction)

        XCTAssertFalse(called)
    }
}
