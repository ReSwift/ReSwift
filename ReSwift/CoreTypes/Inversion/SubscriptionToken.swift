//
//  SubscriptionToken.swift
//  ReSwift
//
//  Created by Christian Tietze on 2019-08-05.
//  Copyright © 2019 ReSwift. All rights reserved.
//

/// Can be used to unsubscribe single subscriptions if an object should have multiple active subscriptions.
public final class SubscriptionToken: Hashable {
    private let objectIdentifier: ObjectIdentifier

    internal let subscriber: AnyObject
    internal let disposable: Disposable?

    internal init(subscriber: AnyObject, disposable: Disposable?) {
        self.subscriber = subscriber
        self.disposable = disposable
        self.objectIdentifier = ObjectIdentifier(subscriber)
    }

    internal func isRepresenting(subscriber: AnyStoreSubscriber) -> Bool {
        return self.subscriber === subscriber
    }

    public static func == (lhs: SubscriptionToken, rhs: SubscriptionToken) -> Bool {

        return lhs.objectIdentifier == rhs.objectIdentifier
    }

    #if swift(>=5.0)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.objectIdentifier)
    }
    #elseif swift(>=4.2)
    #if compiler(>=5.0)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.objectIdentifier)
    }
    #else
    public var hashValue: Int {
        return self.objectIdentifier.hashValue
    }
    #endif
    #else
    public var hashValue: Int {
        return self.objectIdentifier.hashValue
    }
    #endif
}
