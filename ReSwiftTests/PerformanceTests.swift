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
        func sink() {
            // Do nothing
        }
    }

    func testNotify() {
        self.subscribers.forEach { _ = store.objectWillChange.sink(receiveValue: $0.sink) }
        self.measure {
            self.store.dispatch(MockAction())
        }
    }

    func testSubscribe() {
        self.measure {
            self.subscribers.forEach { _ = store.objectWillChange.sink(receiveValue: $0.sink) }
        }
    }
}
