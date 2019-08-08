//
//  AtomicBool.swift
//  ReSwift-iOS
//
//  Created by 钟武 on 2018/5/2.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import Foundation
/**
 Struct is only used internally in ReSwift to implements atomic bool operation.
 */
internal struct AtomicBool {
    private var flag: UInt8 = 0
    internal var value: Bool {
        get { return flag != 0}
        set {
            if newValue {
                OSAtomicTestAndSet(7, &flag)
            } else {
                OSAtomicTestAndClear(7, &flag)
            }
        }
    }
}
