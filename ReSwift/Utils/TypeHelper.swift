//
//  TypeHelper.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

/**
 Method is only used internally in ReSwift to cast the generic `StateType` to a specific
 type expected by reducers / store subscribers.

 - parameter action: An action that will be passed to `handleAction`.
 - parameter state: A generic state type that will be casted to `SpecificStateType`.
 - parameter function: The `handleAction` method.
 - returns: A `StateType` from `handleAction` or the original `StateType` if it cannot be
            casted to `SpecificStateType`.
 */
#if swift(>=3)
@discardableResult
func withSpecificTypes<SpecificStateType, Action>(
        _ action: Action,
        state genericStateType: StateType?,
        function: (_ action: Action, _ state: SpecificStateType?) -> SpecificStateType
    ) -> StateType {
        guard let genericStateType = genericStateType else {
            return function(action, nil) as! StateType
        }

        guard let specificStateType = genericStateType as? SpecificStateType else {
            return genericStateType
        }

        return function(action, specificStateType) as! StateType
}
#else
func withSpecificTypes<SpecificStateType, Action>(
        action: Action,
        state genericStateType: StateType?,
        @noescape function: (action: Action, state: SpecificStateType?) -> SpecificStateType
    ) -> StateType {
        guard let genericStateType = genericStateType else {
            return function(action: action, state: nil) as! StateType
        }

        guard let specificStateType = genericStateType as? SpecificStateType else {
            return genericStateType
        }

        return function(action: action, state: specificStateType) as! StateType
}
#endif
