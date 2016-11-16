//
//  Reducer.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol AnyObservableReducer {
    func _handleAction(action: Action, state: StateType) -> StateType
}

public protocol ObservableReducer: AnyObservableReducer {
    associatedtype ReducerStateType

    func handleAction(action: Action, state: ReducerStateType) -> ReducerStateType
}

extension ObservableReducer {
    public func _handleAction(action: Action, state: StateType) -> StateType {
        return withObservableSpecificTypes(action, state: state, function: handleAction)
    }
}
