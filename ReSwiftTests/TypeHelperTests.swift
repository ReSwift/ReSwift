//
//  TypeHelperTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/20/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import XCTest
@testable import ReSwift

struct AppState1: StateType {}
struct AppState2: StateType {}

// swiftlint:disable function_body_length
class TypeHelper: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // f_withSpecificTypes

    func testCallsMethodsSourceCasted() {
    // calls methods if the source type can be casted into the function signature type
        var called = false
        let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
            called = true

            return state ?? AppState1()
        }

        _ = withSpecificTypes(StandardAction(type: ""), state: AppState1(), function: reducerFunction)

        XCTAssertTrue(called)
    }

    func testCallsMethodIfSourceNil() {
        // calls the method if the source type is nil") {
        var called = false
        let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
            called = true

            return state ?? AppState1()
        }

        _ = withSpecificTypes(StandardAction(type: ""), state: nil, function: reducerFunction)

        XCTAssertTrue(called)
    }

    func testNotCalledIfSourceTypeCantBeCasted() {
        // doesn't call if source type can't be casted to function signature type
        var called = false
        let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
            called = true

            return state ?? AppState1()
        }

        _ = withSpecificTypes(StandardAction(type: ""), state: AppState2(), function: reducerFunction)

        XCTAssertFalse(called)
    }
}
// swiftlint:enable function_body_length
