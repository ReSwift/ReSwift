//
//  Reducer.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyReducer {
    func _handleAction(action: Action, state: StateType?) -> StateType
}

public protocol Reducer: AnyReducer {
    #if swift(>=2.2)
    associatedtype ReducerStateType
    #else
    typealias ReducerStateType
    #endif

    func handleAction(action: Action, state: ReducerStateType?) -> ReducerStateType
}

extension Reducer {
    public func _handleAction(action: Action, state: StateType?) -> StateType {
        return withSpecificTypes(action, state: state, function: handleAction)
    }
}
