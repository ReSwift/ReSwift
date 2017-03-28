//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public typealias DispatchFunction = (Action) -> Void
public typealias GetState = () -> StateType?
public typealias Middleware = (@escaping DispatchFunction, @escaping GetState)
    -> (@escaping DispatchFunction) -> DispatchFunction
