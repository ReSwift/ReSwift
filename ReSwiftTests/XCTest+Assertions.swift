//
//  Assertions
//  Copyright © 2015 mohamede1945. All rights reserved.
//  https://github.com/mohamede1945/AssertionsTestingExample
//

import Foundation
import XCTest
/**
 @testable import for internal testing of `Assertions.fatalErrorClosure`
 */
@testable import ReSwift

private let noReturnFailureWaitTime = 0.1


public extension XCTestCase {

    #if swift(>=3)
    /**
     Expects an `fatalError` to be called.
     If `fatalError` not called, the test case will fail.

     - parameter expectedMessage: The expected message to be asserted to the one passed to the
     `fatalError`. If nil, then ignored.
     - parameter file:            The file name that called the method.
     - parameter line:            The line number that called the method.
     - parameter testCase:        The test case to be executed that expected to fire the assertion
     method.
     */
    public func expectFatalError(expectedMessage: String? = nil, file: StaticString = #file,
                                 line: UInt = #line, testCase: @escaping () -> Void) {
        expectAssertionNoReturnFunction(
            functionName: "fatalError",
            file: file,
            line: line,
            function: { (caller: @escaping (String) -> Void) -> Void in

                Assertions.fatalErrorClosure = { message, _, _ in caller(message) }

        }, expectedMessage: expectedMessage, testCase: testCase) { _ in
            Assertions.fatalErrorClosure = Assertions.swiftFatalErrorClosure
        }
    }

    // MARK:- Private Methods

    // swiftlint:disable function_parameter_count
    private func expectAssertionNoReturnFunction(
        functionName funcName: String,
        file: StaticString,
        line: UInt,
        function: (_ caller: @escaping (String) -> Void) -> Void,
        expectedMessage: String? = nil,
        testCase: @escaping () -> Void,
        cleanUp: @escaping () -> ()) {

        let asyncExpectation = futureExpectation(withDescription: funcName + "-Expectation")
        var assertionMessage: String? = nil

        function { (message) -> Void in
            assertionMessage = message
            asyncExpectation.fulfill()
        }

        // act, perform on separate thead because a call to function runs forever
        dispatchUserInitiatedAsync(execute: testCase)

        waitForFutureExpectations(withTimeout: noReturnFailureWaitTime) { _ in
            defer { cleanUp() }
            guard let assertionMessage = assertionMessage else {
                XCTFail(funcName + " is expected to be called.", file: file, line: line)
                return
            }
            if let expectedMessage = expectedMessage {
                XCTAssertEqual(assertionMessage, expectedMessage, funcName +
                    " called with incorrect message.", file: file, line: line)
            }
        }
    }
    // swiftlint:enable function_parameter_count
    #else
    /**
     Expects an `fatalError` to be called.
     If `fatalError` not called, the test case will fail.

     - parameter expectedMessage: The expected message to be asserted to the one passed to the
     `fatalError`. If nil, then ignored.
     - parameter file:            The file name that called the method.
     - parameter line:            The line number that called the method.
     - parameter testCase:        The test case to be executed that expected to fire the assertion
     method.
     */
    public func expectFatalError(expectedMessage: String? = nil, file: StaticString = #file,
                                 line: UInt = #line, testCase: () -> Void) {
        expectAssertionNoReturnFunction(
            functionName: "fatalError",
            file: file,
            line: line,
            function: { (caller) -> Void in

                Assertions.fatalErrorClosure = { message, _, _ in caller(message) }

        }, expectedMessage: expectedMessage, testCase: testCase) { _ in
            Assertions.fatalErrorClosure = Assertions.swiftFatalErrorClosure
        }
    }

    // MARK:- Private Methods

    // swiftlint:disable function_parameter_count
    private func expectAssertionNoReturnFunction(
        functionName funcName: String,
        file: StaticString,
        line: UInt,
        function: (caller: (String) -> Void) -> Void,
        expectedMessage: String? = nil,
        testCase: () -> Void,
        cleanUp: () -> ()) {

        let asyncExpectation = futureExpectation(withDescription: funcName + "-Expectation")
        var assertionMessage: String? = nil

        function { (message) -> Void in
            assertionMessage = message
            asyncExpectation.fulfill()
        }

        // act, perform on separate thead because a call to function runs forever
        dispatchUserInitiatedAsync(execute: testCase)

        waitForFutureExpectations(withTimeout: noReturnFailureWaitTime) { _ in
            defer { cleanUp() }
            guard let assertionMessage = assertionMessage else {
                XCTFail(funcName + " is expected to be called.", file: file, line: line)
                return
            }
            if let expectedMessage = expectedMessage {
                XCTAssertEqual(assertionMessage, expectedMessage, funcName +
                    " called with incorrect message.", file: file, line: line)
            }
        }
    }
    // swiftlint:enable function_parameter_count
    #endif
}
