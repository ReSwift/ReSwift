//
//  Cancelable.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-03.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// Intended for side-effects.
protocol Cancelable: Disposable {
    var isDisposed: Bool { get }
}
