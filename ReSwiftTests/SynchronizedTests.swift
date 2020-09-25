//
//  SynchronizedTests.swift
//  ReSwift
//
//  Created by Basem Emara on 2020-08-18.
//  Copyright © 2020 ReSwift Community. All rights reserved.
//

import XCTest
/**
 @testable import for testing of `Utils.Synchronized`
 */
@testable import ReSwift

class SynchronizedTests: XCTestCase {
    private let iterations = 100 // 1_000_000
    private let writeMultipleOf = 10 // 1000
}

extension SynchronizedTests {
    func testSharedVariable() {
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            Database.shared.set(key: "test", value: true)
        }
    }
    private class Database {
        static let shared = Database()
        private var data = Synchronized<[String: Any]>([:])
        func get(key: String) -> Any? {
            return data.value { $0[key] }
        }
        func set(key: String, value: Any) {
            data.value { $0[key] = value }
        }
    }
}

extension SynchronizedTests {
    func testWritePerformance() {
        var temp = Synchronized<Int>(0)
        measure {
            temp.value { $0 = 0 } // Reset
            DispatchQueue.concurrentPerform(iterations: iterations) { _ in
                temp.value { $0 += 1 }
            }
            XCTAssertEqual(temp.value, iterations)
        }
    }
}

extension SynchronizedTests {
    func testReadPerformance() {
        var temp = Synchronized<Int>(0)
        measure {
            temp.value { $0 = 0 } // Reset
            DispatchQueue.concurrentPerform(iterations: iterations) {
                guard $0 % writeMultipleOf != 0 else { return }
                temp.value { $0 += 1 }
            }
            XCTAssertGreaterThanOrEqual(temp.value, iterations / writeMultipleOf)
        }
    }
}
