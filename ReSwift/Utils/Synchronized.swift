//
//  Synchronized.swift
//  ReSwift
//
//  Created by Basem Emara on 2020-08-18.
//  https://basememara.com/creating-thread-safe-generic-values-in-swift/
//
//  Copyright © 2020 ReSwift Community. All rights reserved.
//

import Foundation

/// An object that manages the execution of tasks atomically.
struct Synchronized<Value> {
    private let mutex = DispatchQueue(label: "reswift.github.io.ReSwift.Utils.Synchronized", attributes: .concurrent)
    private var _value: Value
    init(_ value: Value) {
        self._value = value
    }
    /// Returns or modify the thread-safe value.
    var value: Value { return mutex.sync { return _value } }
    /// Submits a block for synchronous, thread-safe execution.
    mutating func value<T>(execute task: (inout Value) throws -> T) rethrows -> T {
        return try mutex.sync(flags: .barrier) { return try task(&_value) }
    }
}
