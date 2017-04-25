import Foundation

public typealias ActionCreator<T> = (_ store: DispatchingStoreType) -> T
public typealias StatedActionCreator<S: StateType, T> = (_ store: DispatchingStoreType, _ getState: @escaping () -> S) -> T

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
    func dispatch(_ action: Action)
    
    @discardableResult
    func dispatch<ReturnValue>(_ actionCreator: ActionCreator<ReturnValue>) -> ReturnValue
    
    @discardableResult
    func dispatch<State: StateType, ReturnValue>(_ actionCreator: StatedActionCreator<State, ReturnValue>) -> ReturnValue
}
