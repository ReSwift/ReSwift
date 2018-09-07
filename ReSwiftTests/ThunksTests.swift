//
//  ThunksTests.swift
//  ReSwift
//
//  Created by Daniel Martín Prieto on 06/09/2018.
//  Copyright © 2018 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

private struct FakeState: StateType {}
private struct FakeAction: Action {}

class ThunkTests: XCTestCase {
    func testAction() {
        let middleware: Middleware<FakeState> = createThunksMiddleware()
        let dispatch: DispatchFunction = { _ in }
        let getState: () -> FakeState? = { nil }
        var nextCalled = false
        let next: DispatchFunction = { _ in nextCalled = true }
        let action = FakeAction()
        middleware(dispatch, getState)(next)(action)
        XCTAssert(nextCalled)
    }
    func testThunk() {
        let middleware: Middleware<FakeState> = createThunksMiddleware()
        let dispatch: DispatchFunction = { _ in }
        let getState: () -> FakeState? = { nil }
        var nextCalled = false
        let next: DispatchFunction = { _ in nextCalled = true }
        var thunkBodyCalled = false
        let thunk = Thunk<FakeState> { _, _ in
            thunkBodyCalled = true
        }
        middleware(dispatch, getState)(next)(thunk)
        XCTAssertFalse(nextCalled)
        XCTAssert(thunkBodyCalled)
    }
}
