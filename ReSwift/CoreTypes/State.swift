//
//  State.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol StateType { }

public protocol EquatableState {
    func isEqualState(to state: Self) -> Bool
}

public extension EquatableState where Self: Equatable {
    public func isEqualState(to state: Self) -> Bool {
        return self == state
    }
}
