//
//  MiddlewareFakes.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import ReSwift

let firstMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in
            if var action = action as? SetValueStringAction {
                action.value = action.value + " First Middleware"
                return next(action)
            } else {
                return next(action)
            }
        }
    }
}

let secondMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in
            if var action = action as? SetValueStringAction {
                action.value = action.value + " Second Middleware"
                return next(action)
            } else {
                return next(action)
            }
        }
    }
}

let dispatchingMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in
            if var action = action as? SetValueAction {
                _ = dispatch?(SetValueStringAction("\(action.value)"))

                return "Converted Action Successfully"
            }

            return next(action)
        }
    }
}

let stateAccessingMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in

            let appState = getState() as? TestStringAppState,
            stringAction = action as? SetValueStringAction

            // avoid endless recursion by checking if we've dispatched exactly this action
            if appState?.testValue == "OK" && stringAction?.value != "Not OK" {
                // dispatch a new action
                _ = dispatch?(SetValueStringAction("Not OK"))

                // and swallow the current one
                return next(StandardAction(type: "No-Op-Action"))
            }

            return next(action)
        }
    }
}
