//
//  TypeHelperTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/20/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import ReSwift

struct AppState1: StateType {}
struct AppState2: StateType {}

// swiftlint:disable function_body_length
class TypeHelper: QuickSpec {

    override func spec() {

        describe("f_withSpecificTypes") {

            it("calls methods if the source type can be casted into the function signature type") {
                var called = false
                let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
                    called = true

                    return state ?? AppState1()
                }

                withSpecificTypes(StandardAction(""), state: AppState1(),
                    function: reducerFunction)

                expect(called).to(beTrue())
            }

            it("calls the method if the source type is nil") {
                var called = false
                let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
                    called = true

                    return state ?? AppState1()
                }

                withSpecificTypes(StandardAction(""), state: nil,
                    function: reducerFunction)

                expect(called).to(beTrue())
            }

            it ("doesn't call if source type can't be casted to function signature type") {
                var called = false
                let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
                    called = true

                    return state ?? AppState1()
                }

                withSpecificTypes(StandardAction(""), state: AppState2(),
                    function: reducerFunction)

                expect(called).to(beFalse())
            }
        }
    }
}
// swiftlint:enable function_body_length