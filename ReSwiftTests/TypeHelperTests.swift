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

class TypeHelper: QuickSpec {

    override func spec() {

        describe("f_withSpecificTypes") {

            it("calls methods if the source type can be casted into the function signature type") {
                var called = false
                let reducerFunction: (AppState1, Action) -> AppState1 = { state, action in
                    called = true

                    return state
                }

                withSpecificTypes(AppState1(), action: StandardAction(""),
                    function: reducerFunction)

                expect(called).to(beTrue())
            }

            it ("doesn't call if source type can't be casted to function signature type") {
                var called = false
                let reducerFunction: (AppState1, Action) -> AppState1 = { state, action in
                    called = true

                    return state
                }

                withSpecificTypes(AppState2(), action: StandardAction(""),
                    function: reducerFunction)

                expect(called).to(beFalse())
            }

        }

    }

}
