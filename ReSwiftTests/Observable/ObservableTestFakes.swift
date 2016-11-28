//
//  ObservableTestFakes.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import ReSwift

class ObservableTestStoreSubscriber<T> {
    var receivedStates: [T] = []
    var subscription: (T) -> Void = { _ in }

    init() {
        subscription = { self.receivedStates.append($0) }
    }

    func newState(state: T) {
        receivedStates.append(state)
    }
}
