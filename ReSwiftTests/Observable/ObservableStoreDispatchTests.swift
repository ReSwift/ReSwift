//
//  ObservableStoreDispatchTests.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 11/25/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

fileprivate typealias ObservableStoreTestType = ObservableStore<ObservableProperty<TestAppState>>

class ObservableStoreDispatchTests: XCTestCase {

    typealias TestSubscriber = TestStoreSubscriber<TestAppState>
    typealias CallbackSubscriber = CallbackStoreSubscriber<TestAppState>

    fileprivate var store: ObservableStoreTestType!
    var reducer: ObservableTestReducer!

    private struct EmptyAction: Action {
    }

    override func setUp() {
        super.setUp()
        reducer = ObservableTestReducer()
        store = ObservableStore(reducer: reducer,
                                stateType: TestAppState.self,
                                observable: ObservableProperty(TestAppState()))
    }

    /**
     it returns the dispatched action
     */
    func testReturnsDispatchedAction() {
        let action = SetValueAction(10)
        let returnValue = store.dispatch(action)

        XCTAssertEqual((returnValue as? SetValueAction)?.value, action.value)
    }

    /**
     it throws an exception when a reducer dispatches an action
     */
    func testThrowsExceptionWhenReducersDispatch() {
        // Expectation lives in the `DispatchingReducer` class
        let reducer = ObservableDispatchingReducer()
        store = ObservableStore(reducer: reducer,
                                stateType: TestAppState.self,
                                observable: ObservableProperty(TestAppState()))
        reducer.store = store
        store.dispatch(SetValueAction(10))
    }

    /**
     it subscribes to the property we pass in and dispatches any new values
     */
    func testLiftingWorksAsExpected() {
        let property = ObservableProperty(SetValueAction(10))
        store = ObservableStore(reducer: reducer,
                                stateType: TestAppState.self,
                                observable: ObservableProperty(TestAppState()))
        store.lift(property)
        property.value = SetValueAction(20)
        XCTAssertEqual(store.observable.value.testValue, 20)
    }
}

// Needs to be class so that shared reference can be modified to inject store
class ObservableDispatchingReducer: XCTestCase, ObservableReducer {
    fileprivate var store: ObservableStoreTestType? = nil

    func handleAction(action: Action, state: TestAppState) -> TestAppState {
        expectFatalError {
            self.store?.dispatch(SetValueAction(20))
        }
        return state
    }
}
