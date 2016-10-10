import XCTest


internal func dispatchAsync(execute work: @escaping @convention(block) () -> Swift.Void) {
    DispatchQueue.global(qos: .default).async(execute: work)
}

internal func dispatchUserInitiatedAsync
    (execute work: @escaping @convention(block) () -> Swift.Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: work)
}

extension XCTestCase {

    internal func futureExpectation(withDescription description: String) -> XCTestExpectation {
        return expectation(description: description)
    }

    internal func waitForFutureExpectations(
        withTimeout timeout: TimeInterval,
        handler: XCWaitCompletionHandler? = nil) {

        waitForExpectations(timeout: timeout, handler: handler)
    }
}
