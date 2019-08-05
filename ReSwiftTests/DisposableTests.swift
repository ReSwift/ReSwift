//
//  DisposableTests.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-05.
//  Copyright © 2019 ReSwift. All rights reserved.
//

import XCTest
@testable import ReSwift

class DisposableTests: XCTestCase {

    func testDisposableClosureIsExecutedOnlyOnce() {
        var counter = 0

        let disposable = createDisposable {
            counter += 1
        }

        XCTAssertEqual(counter, 0)
        disposable.dispose()
        XCTAssertEqual(counter, 1)
        disposable.dispose()
        XCTAssertEqual(counter, 1)
    }
}
