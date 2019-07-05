//  Copyright © 2019 ReSwift Community. All rights reserved.

import XCTest
import ReSwift

import Combine

final class PerformanceTests: XCTestCase {
    struct MockState: StateType {}
    struct MockAction: Action {}

    let subscribers: [MockSubscriber] = (0..<3000).map { _ in MockSubscriber() }
    let store = Store(
        reducer: { _, state in return state },
        state: MockState()
    )

    class MockSubscriber {
        func newState(state: MockState) {
            // Do nothing
        }
    }

    func testNotify() {
        self.subscribers.forEach { _ = store.didChange.sink(receiveValue: $0.newState) }
//        store.didChange.tryRemoveDuplicates(by: <#T##(PerformanceTests.MockState, PerformanceTests.MockState) throws -> Bool#>)
        self.measure {
            self.store.dispatch(MockAction())
        }
    }

    func testSubscribe() {
        self.measure {
            self.subscribers.forEach { _ = store.didChange.sink(receiveValue: $0.newState) }
        }
    }
}
