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
public typealias Middleware =
    (DispatchFunction?, @escaping GetState) -> (@escaping DispatchFunction) -> DispatchFunction
