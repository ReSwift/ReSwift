//
//  TypeHelper.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

/**
 Tries to cast a generic `StateType` to the specific type expected by reducers / store subscribers.

 **NOTE: Method is only used internally.**
*/
func castToExpectedType<SpecificStateType, Action>(action: Action, state: StateType,
	@noescape function: (action: Action, state: SpecificStateType)
	-> SpecificStateType) -> SpecificStateType? {
	return state as? SpecificStateType
}
