//
//  Types.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

public protocol Coding {
    init(dictionary: [String : AnyObject])
    func dictionaryRepresentation() -> [String : AnyObject]
}