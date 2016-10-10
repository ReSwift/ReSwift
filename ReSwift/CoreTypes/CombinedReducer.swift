//
//  MainReducer.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation
/**
 A Reducer that combines multiple reducers into one. You will typically use this reducer during
 initial store setup:

 ```swift
 let reducer = CombinedReducer([IncreaseByOneReducer(), IncreaseByTwoReducer()])
 Store(reducer: reducer, appState: CounterState())
 ```

 The order of the reducers in the array is the order in which the reducers will be invoked.
*/
public struct CombinedReducer: AnyReducer {

    private let reducers: [AnyReducer]

    /// Creates a Combined Reducer from the given list of Reducers
    public init(_ reducers: [AnyReducer]) {
        precondition(reducers.count > 0)

        self.reducers = reducers
    }

    public func _handleAction(action: Action, state: StateType?) -> StateType {
        return reducers.reduce(state) { (currentState, reducer) -> StateType in
            return reducer._handleAction(action: action, state: currentState)
        }!
    }
}
