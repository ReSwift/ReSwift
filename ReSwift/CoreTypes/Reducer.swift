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
    typealias ReducerStateType

    func handleAction(action: Action, state: ReducerStateType?) -> ReducerStateType
}

extension Reducer {
    public func _handleAction(action: Action, state: StateType?) -> StateType {
    	if let state = state {
            guard let specificStateType = castToExpectedType(action, state: state,
    		function: handleAction) else { return state }

    		return handleAction(action, state: specificStateType) as! StateType
    	}

    	return handleAction(action, state: nil) as! StateType
    }
}
