import XCTest

func dispatchAsync(execute work: @escaping @convention(block) () -> Swift.Void) {
    DispatchQueue.global(qos: .default).async(execute: work)
}

func dispatchUserInitiatedAsync
    (execute work: @escaping @convention(block) () -> Swift.Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: work)
}

extension XCTestCase {

    func futureExpectation(withDescription description: String) -> XCTestExpectation {
        return expectation(description: description)
    }

    func waitForFutureExpectations(
        withTimeout timeout: TimeInterval,
        handler: XCWaitCompletionHandler? = nil) {

        waitForExpectations(timeout: timeout, handler: handler)
    }
}
