//
//  Rx.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 10/11/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol StreamType {
    associatedtype ValueType
    func subscribe(_ function: @escaping (ValueType) -> Void) -> SubscriptionReferenceType?
}

public protocol ObservablePropertyType: StreamType {
    var value: ValueType { get set }
}

public protocol SubscriptionReferenceType {
    func dispose()
}

public final class ObservableProperty<ValueType>: ObservablePropertyType {
    public typealias ObservableSubscriptionReferenceType =
        ObservableSubscriptionReference<ValueType>
    internal var subscriptions = [ObservableSubscriptionReferenceType : (ValueType) -> Void]()
    private var subscriptionToken: Int = 0
    public var value: ValueType {
        didSet {
            subscriptions.forEach { $0.value(value) }
        }
    }

    public init(_ value: ValueType) {
        self.value = value
    }

    @discardableResult
    public func subscribe(_ function: @escaping (ValueType) -> Void) -> SubscriptionReferenceType? {
        defer { subscriptionToken += 1 }
        let reference = ObservableSubscriptionReferenceType(key: String(subscriptionToken),
                                                            stream: self)
        subscriptions.updateValue(function,
                                  forKey: reference)
        return reference
    }

    public func unsubscribe(reference: ObservableSubscriptionReferenceType) {
        subscriptions.removeValue(forKey: reference)
    }
}

public struct ObservableSubscriptionReference<T> {
    fileprivate let key: String
    fileprivate weak var stream: ObservableProperty<T>?

    fileprivate init(key: String, stream: ObservableProperty<T>) {
        self.key = key
        self.stream = stream
    }
}

extension ObservableSubscriptionReference: SubscriptionReferenceType {
    public func dispose() {
        stream?.unsubscribe(reference: self)
    }
}

extension ObservableSubscriptionReference: Equatable, Hashable {
    public var hashValue: Int {
        return key.hash
    }

    public static func == <T>(lhs: ObservableSubscriptionReference<T>,
                           rhs: ObservableSubscriptionReference<T>) -> Bool {
        return lhs.key == rhs.key
    }
}

public class SubscriptionReferenceBag {
    fileprivate var references: [SubscriptionReferenceType] = []

    public init() {
    }

    public init(references: SubscriptionReferenceType?...) {
        self.references = references.flatMap({ $0 })
    }

    deinit {
        dispose()
    }

    public func addReference(reference: SubscriptionReferenceType?) {
        if let reference = reference {
            references.append(reference)
        }
    }

    public static func += (lhs: SubscriptionReferenceBag, rhs: SubscriptionReferenceType?) {
        lhs.addReference(reference: rhs)
    }
}

extension SubscriptionReferenceBag: SubscriptionReferenceType {
    public func dispose() {
        references.forEach { $0.dispose() }
        references = []
    }
}
