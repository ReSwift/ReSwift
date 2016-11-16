//
//  ObservableStore.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 11/17/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

/**
 This class is the default implementation of the `ObservableStore` protocol. You will use this store in most
 of your applications. You shouldn't need to implement your own store.
 You initialize the store with a reducer and an initial application state. If your app has multiple
 reducers you can combine them by initializng a `MainReducer` with all of your reducers as an
 argument.
 */

public final class ObservableStore<ObservableProperty: ObservablePropertyType>: ObservableStoreType where ObservableProperty.ValueType: StateType {

    public var dispatchFunction: DispatchFunction!

    private var reducer: AnyObservableReducer
    
    public var observable: ObservableProperty!

    private var isDispatching = false
    
    private var disposeBag = SubscriptionReferenceBag()

    public required convenience init(reducer: AnyObservableReducer, stateType: ObservableProperty.ValueType.Type, observable: ObservableProperty) {
        self.init(reducer: reducer, stateType: stateType, observable: observable, middleware: [])
    }

    public required init(reducer: AnyObservableReducer, stateType: ObservableProperty.ValueType.Type, observable: ObservableProperty, middleware: [Middleware]) {
        self.reducer = reducer
        self.observable = observable

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware
            .reversed()
            .reduce({ [unowned self] action in
                return self._defaultDispatch(action: action)
            }) {
                [weak self] dispatchFunction, middleware in
                let getState = { self?.observable.value }
                return middleware(self?.dispatch, getState)(dispatchFunction)
            }
    }

    public func _defaultDispatch(action: Action) -> Any {
        guard !isDispatching else {
            raiseFatalError(
                "ReSwift:IllegalDispatchFromReducer - Reducers may not dispatch actions.")
        }

        isDispatching = true
        let newState = reducer._handleAction(action: action, state: observable.value) as! ObservableProperty.ValueType
        isDispatching = false

        observable.value = newState

        return action
    }

    @discardableResult
    public func dispatch(_ action: Action) -> Any {
        return dispatchFunction(action)
    }

    @discardableResult
    public func dispatch(_ actionCreatorProvider: @escaping ActionCreator) -> Any {
        let action = actionCreatorProvider(observable.value, self)

        if let action = action {
            dispatch(action)
        }

        return action as Any
    }

    public func dispatch(_ asyncActionCreatorProvider: @escaping AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    public func dispatch(_ actionCreatorProvider: @escaping AsyncActionCreator,
                         callback: DispatchCallback?) {
        actionCreatorProvider(observable.value, self) { actionProvider in
            let action = actionProvider(self.observable.value, self)

            if let action = action {
                self.dispatch(action)
                callback?(self.observable.value)
            }
        }
    }
    
    public func lift<Stream : StreamType>(_ stream: Stream) where Stream.ValueType: Action {
        disposeBag += stream.subscribe { [unowned self] action in
            self.dispatch(action)
        }
    }

    public typealias DispatchCallback = (ObservableProperty.ValueType) -> Void

    public typealias ActionCreator = (_ state: ObservableProperty.ValueType, _ store: ObservableStore) -> Action?

    public typealias AsyncActionCreator = (
        _ state: ObservableProperty.ValueType,
        _ store: ObservableStore,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
    ) -> Void
}
