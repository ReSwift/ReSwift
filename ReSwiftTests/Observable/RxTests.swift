//
//  RxTests.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

@testable import ReSwift
import XCTest

class RxTests: XCTestCase {

    func testObservablePropertySendsNewValues() {
        let property = ObservableProperty(10)
        XCTAssertEqual(property.value, 10)
        property.value = 20
        XCTAssertEqual(property.value, 20)
        property.value = 30
        XCTAssertEqual(property.value, 30)
    }

    func testObservablePropertyDisposesOfReferences() {
        let property = ObservableProperty(())
        let reference = property.subscribe({})
        XCTAssertEqual(property.subscriptions.count, 1)
        reference?.dispose()
        XCTAssertEqual(property.subscriptions.count, 0)
    }

    func testSubscriptionBagDisposesOfReferences() {
        let property = ObservableProperty(())
        let bag = SubscriptionReferenceBag()
        bag += property.subscribe({})
        bag += property.subscribe({})
        XCTAssertEqual(property.subscriptions.count, 2)
        bag.dispose()
        XCTAssertEqual(property.subscriptions.count, 0)
    }

    func testThatDisposingOfAReferenceTwiceIsOkay() {
        let property = ObservableProperty(())
        let reference = property.subscribe({})
        reference?.dispose()
        reference?.dispose()
    }

}
