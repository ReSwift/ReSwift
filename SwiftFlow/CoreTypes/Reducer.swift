//
//  Reducer.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyReducer {
    func _handleAction(state: StateType, action: Action) -> StateType
}

public protocol Reducer: AnyReducer {
    typealias ReducerStateType

    func handleAction(state: ReducerStateType, action: Action) -> ReducerStateType
}

extension Reducer {

    public func _handleAction(state: StateType, action: Action) -> StateType {
        return withSpecificTypes(state, action: action, function: handleAction)
    }

}

protocol PartialReducer: Reducer {
    
    typealias PartialStateType: StateType
    typealias HandledActionType: Action
    
    func get(state: StateType) -> PartialStateType
    func set(partialState: PartialStateType, originalState: StateType) -> StateType
    func handleSupportedAction(partialState: PartialStateType, supportedAction: HandledActionType) -> PartialStateType
}

extension PartialReducer {
    func handleAction(state: StateType, action: Action) -> StateType {
        guard let supportedAction = action as? HandledActionType else {
            return state
        }
        let newState = handleSupportedAction(self.get(state), supportedAction: supportedAction)
        return self.set(newState, originalState: state)
    }
}
