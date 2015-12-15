//
//  MainReducer.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

public struct MainReducer: AnyReducer {

    var reducers: [AnyReducer]

    public init(_ reducers: [AnyReducer]) {
        self.reducers = reducers
    }

    public func _handleAction(var state: StateType, action: Action) -> StateType {
        reducers.forEach { reducer in
            state = reducer._handleAction(state, action: action)
        }

        return state
    }

}
