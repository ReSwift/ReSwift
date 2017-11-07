//
//  AutomaticallySkipRepeatsTests.swift
//  ReSwift
//
//  Created by Daniel Martín Prieto on 03/11/2017.
//  Copyright © 2017 Benjamin Encz. All rights reserved.
//
import XCTest
import ReSwift

class AutomaticallySkipRepeatsTests: XCTestCase {

    private var store: Store<State>!
    private var subscriptionUpdates: Int = 0

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        store = Store<State>(reducer: reducer, state: nil)
        subscriptionUpdates = 0
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        store = nil
        subscriptionUpdates = 0
        super.tearDown()
    }

    func testInitialSubscription() {
        let promise = expectation(description: "First subscription expectation")
        store.subscribe(self) { $0.select { $0.name } }
        promise.fulfill()
        waitForExpectations(timeout: 1) { error in
            guard error == nil else { return }
            XCTAssertTrue(self.subscriptionUpdates == 1)
        }
    }

    func testDispatchUnrelatedActionWithExplicitSkipRepeats() {
        let promise = expectation(description: "First subscription expectation")
        store.subscribe(self) { $0.select { $0.name }.skipRepeats() }
        store.dispatch(ChangeAge(newAge: 30))
        promise.fulfill()
        waitForExpectations(timeout: 1) { error in
            guard error == nil else { return }
            XCTAssertTrue(self.subscriptionUpdates == 1,
                          "Subscriptions updates: \(self.subscriptionUpdates), State: \(self.store.state)")
        }
    }

    func testDispatchUnrelatedActionWithoutExplicitSkipRepeats() {
        let promise = expectation(description: "First subscription expectation")
        store.subscribe(self) { $0.select { $0.name } }
        store.dispatch(ChangeAge(newAge: 30))
        promise.fulfill()
        waitForExpectations(timeout: 1) { error in
            guard error == nil else { return }
            XCTAssertTrue(self.subscriptionUpdates == 1,
                          "Subscriptions updates: \(self.subscriptionUpdates), State: \(self.store.state)")
        }
    }

}

extension AutomaticallySkipRepeatsTests: StoreSubscriber {
    func newState(state: String) {
        subscriptionUpdates += 1
    }
}

private struct State: StateType {
    let age: Int
    let name: String
}

extension State: Equatable {
    static func == (lhs: State, rhs: State) -> Bool {
        return lhs.age == rhs.age && lhs.name == rhs.name
    }
}

struct ChangeAge: Action {
    let newAge: Int
}

private let initialState = State(age: 29, name: "Daniel")

private func reducer(action: Action, state: State?) -> State {
    let defaultState = state ?? initialState
    switch action {
    case let changeAge as ChangeAge:
        return State(age: changeAge.newAge, name: defaultState.name)
    default:
        return defaultState
    }
}
