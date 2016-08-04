import XCTest

#if swift(>=3)
#else
    internal typealias TimeInterval = NSTimeInterval
#endif

internal func dispatchAsync(execute work: @convention(block) () -> Swift.Void) {
    #if swift(>=3)
        DispatchQueue.global(qos: .default).async(execute: work)
    #else
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), work)
    #endif
}


internal func dispatchUserInitiatedAsync(execute work: @convention(block) () -> Swift.Void) {
    #if swift(>=3)
        DispatchQueue.global(qos: .userInitiated).async(execute: work)
    #else
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), work)
    #endif

}

extension XCTestCase {

    internal func futureExpectation(withDescription description: String) -> XCTestExpectation {
        #if swift(>=3)
            return expectation(description: description)
        #else
            return expectationWithDescription(description)
        #endif
    }

    internal func waitForFutureExpectations(
        withTimeout timeout: TimeInterval,
        handler: XCWaitCompletionHandler? = nil) {

        #if swift(>=3)
            waitForExpectations(timeout: timeout, handler: handler)
        #else
            waitForExpectationsWithTimeout(timeout, handler: handler)
        #endif
    }
}
