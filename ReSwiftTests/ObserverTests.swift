//
//  ObserverTests.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-05.
//  Copyright © 2019 ReSwift. All rights reserved.
//

import XCTest
@testable import ReSwift

class ObserverTests: XCTestCase {

    func testConvenienceOn_Next() {
        var observer: AnyObserver<Int>!
        let events: Observable<Int> = Observable.create { obs in
            observer = obs
            return createDisposable()
        }

        var elements = [Int]()

        let subscription = events.subscribe { value in
            elements.append(value)
        }

        XCTAssertEqual(elements, [])

        observer.on(0)

        XCTAssertEqual(elements, [0])

        subscription.dispose()
    }

}
