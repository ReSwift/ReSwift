//
//  Middleware.swift
//  SwiftFlow
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public typealias DispatchFunction =  (ActionType) -> Any
public typealias Middleware = (DispatchFunction, () -> StateType)
                                -> DispatchFunction -> DispatchFunction
