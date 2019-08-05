//
//  ObservableTests.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-05.
//  Copyright © 2019 ReSwift. All rights reserved.
//

import XCTest
@testable import ReSwift

class ObservableTests: XCTestCase {

    class Observer: ObserverType {
        var didReceive: Int?
        func on(_ state: Int) {
            didReceive = state
        }
    }

    func testObservableCreationItselfDoesNotCallTheCreationClosure() {
        var wasCalled = false
        let observable = Observable<Int>.create { _ in
            wasCalled = true
            return createDisposable()
        }

        XCTAssertFalse(wasCalled)
    }

    func testConnectingObservableAffectsObserverIndividually() {
        var count = 0
        let events = Observable<Int>.create { observer in
            count += 1
            observer.on(count)
            return createDisposable()
        }

        let firstObserver = Observer()
        let secondObserver = Observer()
        var subscriptions: [Disposable] = []

        // Precondition
        XCTAssertNil(firstObserver.didReceive)
        XCTAssertNil(secondObserver.didReceive)

        // Subscription executes `create` closure
        subscriptions.append(events.subscribe(firstObserver))
        XCTAssertEqual(firstObserver.didReceive, 1)

        // Further subscriptions execute `create` closure for the new observer only
        subscriptions.append(events.subscribe(secondObserver))
        XCTAssertEqual(firstObserver.didReceive, 1)
        XCTAssertEqual(secondObserver.didReceive, 2)

        subscriptions = []
    }

}
