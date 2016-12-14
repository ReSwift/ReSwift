//
//  EquatableStateTests.swift
//  ReSwift
//
//  Created by SiSo Mollov on 12/14/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import XCTest
@testable import ReSwift

class EquatableStateTests: XCTestCase {

    fileprivate var store: Store<FakeAppState>!

    override func setUp() {
        super.setUp()

        store = Store(reducer: fakeAppStateReducer, state: nil)
    }

    func testEquatableStateSubscription() {
        let subscriber1 = FakeSubscriber()
        let subscriber2 = FakeSubscriber()

        store.subscribe(subscriber1) { state in
            state.subState1
        }

        store.subscribe(subscriber2) { state in
            state.substate2
        }

        store.dispatch(FakeSubstateAction.one)

        XCTAssert(subscriber1.newStateCount == 2)
        XCTAssert(subscriber2.newStateCount == 1)

    }
}

fileprivate struct FakeAppState: StateType {

    var subState1: FakeSubstate
    var substate2: FakeSubstate
}

fileprivate func fakeAppStateReducer(action: Action, state: FakeAppState?) -> FakeAppState {
    var state =
        state ?? FakeAppState(
            subState1: fakeSubstateReducer(action: action, state: state?.subState1),
            substate2: fakeSubstateReducer(action: action, state: state?.substate2)
        )

    switch action as? FakeSubstateAction {
    case .one?:
        state.subState1 = fakeSubstateReducer(action: action, state: state.subState1)
    case .two?:
        state.substate2 = fakeSubstateReducer(action: action, state: state.substate2)
    default:
        break
    }

    return state
}

fileprivate struct FakeSubstate: EquatableState {

    var uuid: String = UUID().uuidString
    var testValue: Int = 0
}

fileprivate func fakeSubstateReducer(action: Action, state: FakeSubstate?) -> FakeSubstate {
    var state = state ?? FakeSubstate()

    if action is FakeSubstateAction {
        state.uuid = UUID().uuidString
        state.testValue += 1
    }

    return state
}

fileprivate enum FakeSubstateAction: Action {
    case one, two
}

fileprivate class FakeSubscriber: EquatableStateStoreSubscriber {
    var stateUUID: String?

    typealias StoreSubscriberStateType = FakeSubstate
    var newStateCount = 0

    func newState(state: FakeSubstate) {
        newStateCount += 1
    }
}
