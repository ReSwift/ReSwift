//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public typealias DispatchFunction = (Action) -> Void
public typealias Middleware<State> = (@escaping DispatchFunction, @escaping () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction

public typealias SideEffectOnlyMiddleware<State> = (Action, State?) -> Void

public enum Middlewares {
    case normal(Middleware<StateType>)
    case simple(SideEffectOnlyMiddleware<StateType>)
}

public func makeMiddleware(for sideEffect: @escaping SideEffectOnlyMiddleware<StateType>) -> Middleware<StateType> {
    return { dispatch, getState in
        { next in
            { action in
                sideEffect(action, getState())
                next(action)
            }
        }
    }
}
