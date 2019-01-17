import XCTest
import ReSwift

final class PerformanceTests: XCTestCase {
    struct MockState: StateType {}
    struct MockAction: Action {}

    let subscribers: [MockSubscriber] = (0..<3000).map { _ in MockSubscriber() }
    let store = Store(
        reducer: { _, state in return state ?? MockState() },
        state: MockState(),
        automaticallySkipsRepeats: false
    )

    class MockSubscriber: StoreSubscriber {
        func newState(state: MockState) {
            // Do nothing
        }
    }

    func testNotify() {
        self.subscribers.forEach(self.store.subscribe)
        self.measure {
            self.store.dispatch(MockAction())
        }
    }

    func testSubscribe() {
        self.measure {
            self.subscribers.forEach(self.store.subscribe)
        }
    }
}
