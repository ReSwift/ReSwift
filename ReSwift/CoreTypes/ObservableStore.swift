//
//  ObservableStore.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 11/17/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

/**
 This class is the default implementation of the `ObservableStore` protocol. You will use this 
 store in most of your applications. You shouldn't need to implement your own store.
 You initialize the store with a reducer and an initial application state. If your app has multiple
 reducers you can combine them by initializng a `MainReducer` with all of your reducers as an
 argument.
 */

public class ObservableStore<ObservableProperty: ObservablePropertyType>: ObservableStoreType
                where ObservableProperty.ValueType: StateType {

    public var dispatchFunction: DispatchFunction!

    private var reducer: AnyReducer

    public var observable: ObservableProperty!

    private var isDispatching = false

    private var disposeBag = SubscriptionReferenceBag()

    public required convenience init(reducer: AnyReducer,
                                     stateType: ObservableProperty.ValueType.Type,
                                     observable: ObservableProperty) {
        self.init(reducer: reducer, stateType: stateType, observable: observable, middleware: [])
    }

    public required init(reducer: AnyReducer,
                         stateType: ObservableProperty.ValueType.Type,
                         observable: ObservableProperty,
                         middleware: [Middleware]) {
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
        let newState = reducer._handleAction(action: action, state: observable.value)
        isDispatching = false

        observable.value = newState as! ObservableProperty.ValueType

        return action
    }

    @discardableResult
    public func dispatch(_ action: Action) -> Any {
        return dispatchFunction(action)
    }

    public func lift<Stream: StreamType>(_ stream: Stream) where Stream.ValueType: Action {
        disposeBag += stream.subscribe { [unowned self] action in
            self.dispatch(action)
        }
    }
}
