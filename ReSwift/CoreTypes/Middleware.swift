//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public typealias DispatchFunction = (Action) -> Any
public typealias GetState = () -> StateType?
#if swift(>=3)
public typealias Middleware =
    (DispatchFunction?, @escaping GetState) -> (@escaping DispatchFunction) -> DispatchFunction
#else
public typealias Middleware =
    (DispatchFunction?, GetState) -> (DispatchFunction) -> DispatchFunction
#endif
