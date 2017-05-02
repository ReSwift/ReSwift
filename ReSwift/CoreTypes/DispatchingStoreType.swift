import Foundation

public typealias ActionCreator<T> = (_ store: DispatchingStoreType) -> T
public typealias AsyncActionCreator<T> = (_ store: DispatchingStoreType, _ next: (T) -> Void) -> Void

/**
 Defines the interface of a dispatching, stateless Store in ReSwift. `StoreType` is
 the default usage of this interface. Can be used for store variables where you don't
 care about the state, but want to be able to dispatch actions.
 */
public protocol DispatchingStoreType {

    /**
     Dispatches an action. This is the simplest way to modify the stores state.

     Example of dispatching an action:

     ```
     store.dispatch( CounterAction.IncreaseCounter )
     ```

     - parameter action: The action that is being dispatched to the store
     - returns: By default returns the dispatched action, but middlewares can change the
     return type, e.g. to return promises
     */
    @discardableResult
    func dispatch(_ actions: Any...) -> Any
}

extension DispatchingStoreType {
    public func dispatch(_ action: Action) {
        dispatch(action as Any)
    }

    public func dispatch<ReturnValue>(_ actionCreator: @escaping ActionCreator<ReturnValue>) -> ReturnValue {
        guard let result = dispatch(actionCreator as ActionCreator<Any>) as? ReturnValue else {
            raiseFatalError("ReSwift: You tried to dispatch action creator with different return value type")
        }
        return result
    }
    
    public func dispatch<CallbackParam>(_ asyncActionCreator: @escaping AsyncActionCreator<CallbackParam>, callback: @escaping (CallbackParam) -> Void) {
        let typeErasedActionCreator: AsyncActionCreator<Any> = { store, next in
            asyncActionCreator(store, { (param) in
                next(param)
            })
        }
        
        let typeErasedCallback: (Any) -> Void = { param in
            guard let param = param as? CallbackParam else {
                raiseFatalError()
            }
            callback(param)
        }
        
        dispatch(typeErasedActionCreator as Any, typeErasedCallback as Any)
    }
}
