//
//  ObservableCombinedReducer.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 11/11/15.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation
/**
 A Reducer that combines multiple reducers into one. You will typically use this reducer during
 initial store setup:
 
 ```swift
 let reducer = ObservableCombinedReducer([IncreaseByOneReducer(), IncreaseByTwoReducer()])
 ObservableStore(reducer: reducer, 
                stateType: CounterState.self, 
                observable: ObservableProperty(CounterState()))
 ```
 
 The order of the reducers in the array is the order in which the reducers will be invoked.
 */
public struct ObservableCombinedReducer: AnyObservableReducer {

    private let reducers: [AnyObservableReducer]

    /// Creates a Combined Reducer from the given list of Reducers
    public init(_ reducers: AnyObservableReducer...) {
        self.reducers = reducers
    }

    public func _handleAction(action: Action, state: StateType) -> StateType {
        return reducers.reduce(state) { (currentState, reducer) -> StateType in
            return reducer._handleAction(action: action, state: currentState)
        }
    }
}
