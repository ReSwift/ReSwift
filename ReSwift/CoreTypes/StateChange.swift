//
//  StateChange.swift
//  ReSwift
//
//  Created by Virgilio Favero Neto on 4/02/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

protocol StateChangeType {
    associatedtype State
    associatedtype ChangedState

    var getState: () -> State? { get }
    var automaticallySkipsEquatable: Bool { get }
    
    func select<SelectedState>(_ selector: @escaping (State) -> SelectedState) -> SelectedStateChange<State, SelectedState>
    func skip(when skip: @escaping (_ oldState: State, _ newState: State) -> Bool) -> SkippedStateChange<State>
    func only(when only: @escaping (_ oldState: State, _ newState: State) -> Bool) -> OnlyWhenStateChange<State>

    func subscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreSubscriberStateType == State

    func onChange(oldState: ChangedState, newState: ChangedState)
}

extension StateChangeType {
    public func select<SelectedState>(
        _ selector: @escaping (State) -> SelectedState)
        -> SelectedStateChange<State, SelectedState>
    {
        return SelectedStateChange(
            getState: self.getState,
            transform: selector,
            automaticallySkipsEquatable: self.automaticallySkipsEquatable)
    }

    public func skip(
        when skip: @escaping (_ oldState: State, _ newState: State) -> Bool)
        -> SkippedStateChange<State>
    {
        return SkippedStateChange(
            getState: self.getState,
            skip: skip,
            automaticallySkipsEquatable: self.automaticallySkipsEquatable)
    }

    public func only(
        when condition: @escaping (_ oldState: State, _ newState: State) -> Bool)
        -> OnlyWhenStateChange<State>
    {
        return OnlyWhenStateChange(
            getState: self.getState,
            condition: condition,
            automaticallySkipsEquatable: self.automaticallySkipsEquatable)
    }
}

public class SkippedStateChange<SkippedState>: StateChangeType {

    public typealias State = SkippedState
    public typealias ChangedState = SkippedState
    public typealias Skip = (_ oldState: State, _ newState: State) -> Bool

    internal let getState: () -> SkippedState?
    internal let skip: Skip
    internal let automaticallySkipsEquatable: Bool

    fileprivate(set) internal var subscribers: [WeakSubscriberBox] = []

    public init(
        getState: @escaping () -> SkippedState?,
        skip: @escaping Skip,
        automaticallySkipsEquatable: Bool)
    {
        self.getState = getState
        self.skip = skip
        self.automaticallySkipsEquatable = automaticallySkipsEquatable
    }

    public func onChange(oldState: SkippedState, newState: SkippedState) {
        guard !skip(oldState, newState) else { return }

        for weakSubscriberBox in subscribers {
            weakSubscriberBox.subscriber?._newState(
                oldState: oldState as Any,
                state: newState as Any,
                automaticallySkipsEquatable: self.automaticallySkipsEquatable)
        }
    }

    public func subscribe<S>(_ subscriber: S) where S : StoreSubscriber, SkippedState == S.StoreSubscriberStateType {
        self.subscribers.append(WeakSubscriberBox(subscriber: subscriber))
        subscriber._initialState(state: self.getState() as Any)
    }
}

public class OnlyWhenStateChange<SkippedState>: StateChangeType {

    public typealias State = SkippedState
    public typealias ChangedState = SkippedState
    public typealias Filter = (_ oldState: State, _ newState: State) -> Bool

    internal let getState: () -> SkippedState?
    internal let condition: Filter
    internal let automaticallySkipsEquatable: Bool

    fileprivate(set) internal var subscribers: [WeakSubscriberBox] = []

    public init(
        getState: @escaping () -> SkippedState?,
        condition: @escaping Filter,
        automaticallySkipsEquatable: Bool)
    {
        self.getState = getState
        self.condition = condition
        self.automaticallySkipsEquatable = automaticallySkipsEquatable
    }

    public func onChange(oldState: SkippedState, newState: SkippedState) {
        guard condition(oldState, newState) else { return }

        for weakSubscriberBox in subscribers {
            weakSubscriberBox.subscriber?._newState(
                oldState: oldState as Any,
                state: newState as Any,
                automaticallySkipsEquatable: self.automaticallySkipsEquatable)
        }
    }

    public func subscribe<S>(_ subscriber: S) where S : StoreSubscriber, SkippedState == S.StoreSubscriberStateType {
        self.subscribers.append(WeakSubscriberBox(subscriber: subscriber))
        subscriber._initialState(state: self.getState() as Any)
    }
}

public class SelectedStateChange<SourceState, SelectedState>: StateChangeType {

    public typealias State = SelectedState
    public typealias ChangedState = SourceState
    public typealias Transformation = (SourceState) -> SelectedState
    
    internal let getState: () -> SelectedState?
    internal let transform: Transformation
    internal let automaticallySkipsEquatable: Bool

    fileprivate(set) internal var subscribers: [WeakSubscriberBox] = []

    init(
        getState: @escaping () -> SourceState?,
        transform: @escaping Transformation,
        automaticallySkipsEquatable: Bool)
    {
        self.getState = { getState().map { transform($0) } }
        self.transform = transform
        self.automaticallySkipsEquatable = automaticallySkipsEquatable
    }

    func onChange(oldState: SourceState, newState: SourceState) {
        for weakSubscriberBox in subscribers {
            weakSubscriberBox.subscriber?._newState(
                oldState: transform(oldState) as Any,
                state: transform(newState) as Any,
                automaticallySkipsEquatable: self.automaticallySkipsEquatable)
        }
    }

    public func subscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreSubscriberStateType == SelectedState {
        self.subscribers.append(WeakSubscriberBox(subscriber: subscriber))
        subscriber._initialState(state: self.getState() as Any)
    }
}

/// Represents a change of state in the store. The chain of state changes determines which new
/// values from the store are forwarded to the subscriber, and how they are transformed.
///
/// `StateChange` acts as a very-light weight signal/observable that you might know from
/// reactive programming libraries.
public class StateChange<StateChangeState>: StateChangeType {

    public typealias State = StateChangeState
    typealias ChangedState = StateChangeState

    private(set) internal var getState: () -> StateChangeState?
    internal let automaticallySkipsEquatable: Bool
    fileprivate(set) internal var subscribers: [WeakSubscriberBox] = []

    init(
        getState: @escaping () -> StateChangeState?,
        automaticallySkipsEquatable: Bool) 
    {
        self.getState = getState
        self.automaticallySkipsEquatable = automaticallySkipsEquatable
    }

    func onChange(oldState: StateChangeState, newState: StateChangeState) {
        for weakSubscriberBox in self.subscribers {
            weakSubscriberBox.subscriber?._newState(
                oldState: oldState,
                state: newState,
                automaticallySkipsEquatable: self.automaticallySkipsEquatable)
        }
    }

    public func subscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreSubscriberStateType == State {
        self.subscribers.append(WeakSubscriberBox(subscriber: subscriber))
        subscriber._initialState(state: self.getState() as Any)
    }
}

struct WeakSubscriberBox {
    weak var subscriber: AnyStoreSubscriber?
}
