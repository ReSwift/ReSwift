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

            it("sets `didCast = true` if the source type can be cast to function signature type") {
                var didCast = false
                let reducerFunction: (Action, AppState1) -> AppState1 = { action, state in
                    return state
                }

                if let _ = castToExpectedType(StandardAction(""), state: AppState1(),
                    function: reducerFunction) {
                        didCast = true
                }

                expect(didCast).to(beTrue())
            }

            it ("sets `didCast = false` if source type can't be cast to function signature type") {
                var didCast = false
                let reducerFunction: (Action, AppState1) -> AppState1 = { action, state in
                    return state
                }

                if let _ = castToExpectedType(StandardAction(""), state: AppState2(),
                    function: reducerFunction) {
                        didCast = true
                }

                expect(didCast).to(beFalse())
            }

        }

    }

}
// swiftlint:enable function_body_length
