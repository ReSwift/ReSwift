//
//  StoreDispatchTests.swift
//  ReSwift
//
//  Created by Karl Bowden on 20/07/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

class StoreDispatchTests: XCTestCase {

    typealias TestSubscriber = TestStoreSubscriber<TestAppState>
    typealias CallbackSubscriber = CallbackStoreSubscriber<TestAppState>

    var store: Store<TestAppState>!
    var reducer: TestReducer!

    override func setUp() {
        super.setUp()
        reducer = TestReducer()
        store = Store(reducer: reducer.handleAction, state: TestAppState())
    }

    /**
     it throws an exception when a reducer dispatches an action
     */
    func testThrowsExceptionWhenReducersDispatch() {
        // Expectation lives in the `DispatchingReducer` class
        let reducer = DispatchingReducer()
        store = Store(reducer: reducer.handleAction, state: TestAppState())
        reducer.store = store
        store.dispatch(SetValueAction(10))
    }
}

// Needs to be class so that shared reference can be modified to inject store
class DispatchingReducer: XCTestCase {
    var store: Store<TestAppState>?

    func handleAction(action: Action, state: TestAppState?) -> TestAppState {
        expectFatalError {
            self.store?.dispatch(SetValueAction(20))
        }
        return state ?? TestAppState()
    }
}
