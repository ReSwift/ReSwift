//
//  SubscriberWrapper.swift
//  ReSwift
//
//  Created by Virgilio Favero Neto on 4/02/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

struct Subscription<State: StateType> {
    fileprivate(set) weak var subscriber: AnyStoreSubscriber? = nil
    let selector: ((State) -> Any)?
}
