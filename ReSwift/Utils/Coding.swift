//
//  Types.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

public protocol Coding {
    init?(dictionary: [String: AnyObject])
    var dictionaryRepresentation: [String: AnyObject] { get }
}
