//
//  Thunk.swift
//  ReSwift
//
//  Created by Daniel Martín Prieto on 06/09/2018.
//  Copyright © 2018 Benjamin Encz. All rights reserved.
//

import Foundation

public struct Thunk<State: StateType>: Action {
    let body: (_ dispatch: @escaping DispatchFunction, _ getState: @escaping () -> State?) -> Void
    public init(body: @escaping (
                _ dispatch: @escaping DispatchFunction,
                _ getState: @escaping () -> State?) -> Void) {
        self.body = body
    }
}

public func createThunksMiddleware<State: StateType>() -> Middleware<State> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let thunk as Thunk<State>:
                    thunk.body(dispatch, getState)
                default:
                    next(action)
                }
            }
        }
    }
}
