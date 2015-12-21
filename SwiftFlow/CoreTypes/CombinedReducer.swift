//
//  MainReducer.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

public struct CombinedReducer: AnyReducer {

    private let reducers: [AnyReducer]

    public init(_ reducers: [AnyReducer]) {
        self.reducers = reducers
    }

    public func _handleAction(state: StateType, action: Action) -> StateType {
        return reducers.reduce(state) { currentState, reducer in
            reducer._handleAction(currentState, action: action)
        }
    }

}
