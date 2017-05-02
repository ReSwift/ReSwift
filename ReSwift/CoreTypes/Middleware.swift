//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public typealias DispatchFunction = ([Any]) -> Any
public typealias Middleware<State> = (DispatchingStoreType, @escaping () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction

public func thunkMiddleware<State>(store: DispatchingStoreType, getState: () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction {
    return { next in
        return { actions in
            if let actionCreator = actions.first as? ActionCreator<Any> {
                return actionCreator(store)
            }

            if let actionCreator = actions.first as? AsyncActionCreator<Any> {
                if let callback = actions.last as? (Any) -> Void {
                    return actionCreator(store, callback)
                }
            }

            return next(actions)
        }
    }
}
