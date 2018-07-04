import Foundation
import ReSwift

class MiddlewareExecutor<T: StateType> {
    /**
     Method need be override to work
     
     @param Action action to execute this middleware
     @param T current state
     @param DispatchFunction callback function conform type alias DispatchFunction
     @return Action return an action, if return nil the queue will stop
     */
    func execute(action: Action, state: T?, nextDispatcher: @escaping DispatchFunction) -> Action? {
        return action
    }
}

class MiddlewaresCollection<T: StateType> {
    private var _middlewares: [Middleware<T>]
    init() {
        self._middlewares = []
    }
    /**
     Concat other MiddlewaresCollection with this
     
     @param MiddlewaresCollection MiddlewaresCollection to concat
     @return MiddlewaresCollection return self
     */
    func concact(withCollection: MiddlewaresCollection) -> MiddlewaresCollection {
        self._middlewares = _middlewares + withCollection.middlewares
        return self
    }
    /**
     Method to add an executor in middleware collection
     
     @param MiddlewareExecutor<T> add executor to collection with collection type
     @return MiddlewaresCollection return self
     */
    func add(_ middlewareItens: MiddlewareExecutor<T>...) -> MiddlewaresCollection {
        for item in middlewareItens {
            self._middlewares.append ({ (_, state) -> (@escaping DispatchFunction) -> DispatchFunction in
                return { next in
                    return { action in
                        if let nextAction = item.execute(action: action, state: state(), nextDispatcher: next) {
                            next(nextAction)
                        }
                    }
                }
            })
        }
        return self
    }
    /**
     List of middlewares to store
     */
    public var middlewares: [Middleware<T>] {
        return self._middlewares
    }
}
