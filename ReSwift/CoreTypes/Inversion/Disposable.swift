//
//  Disposable.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

public protocol Disposable {
    /// Dispose resource callback.
    func dispose()
}

/// Create disposable that does nothing when cleaning up resources.
func createDisposable() -> Disposable {
    return NullDisposable.noOp
}

private struct NullDisposable : Disposable {
    fileprivate static let noOp: Disposable = NullDisposable()

    private init() {}

    public func dispose() {
        // no-op
    }
}
