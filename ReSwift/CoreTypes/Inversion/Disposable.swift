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

func createDisposable(with action: @escaping () -> Void) -> Disposable {
    return AnonymousDisposable(action: action)
}

private struct NullDisposable: Disposable {
    fileprivate static let noOp: Disposable = NullDisposable()

    init() {}

    func dispose() {
        // no-op
    }
}

private final class AnonymousDisposable: Disposable {
    public typealias DisposeAction = () -> Void

    private var disposeAction: DisposeAction?

    init(action: @escaping DisposeAction) {
        self.disposeAction = action
    }

    func dispose() {
        guard let action = self.disposeAction else { return }
        self.disposeAction = nil
        action()
    }
}
