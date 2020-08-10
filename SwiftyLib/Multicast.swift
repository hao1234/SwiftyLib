//
//  Multicast.swift
//  SwiftyLib
//
//  Created by Nguyen Vu Hao on 8/10/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

final public class Multicast<T> {
    
    private var weakObjects: [WeakObject<AnyObject>] = []

    /// Initialize Multicast<T>
    public init() {}

    /// Append an instance as weak reference into array.
    /// That'll hold your instance to invoke but It do not retain reference counting to avoid leaking
    /// - Parameter object: The instance to invoke events
    public func append(_ object: T) {
        let object = object as AnyObject
        weakObjects.append(WeakObject(object: object))
    }

    /// Remove an instance that appended in WeakObjects array.
    /// Should be called when your instance delloc
    /// - Parameter object: The instance object to remove
    public func remove(_ object: T) {
        let object = object as AnyObject
        weakObjects = weakObjects.filter { $0.object !== object }
    }

    /// Invoke event to instance that appended into
    /// - Parameter function: The callback foreach instance that you can invoke.
    /// The callback invoke on the thread be invoking that function
    public func invoke(_ function: (T) -> ()) {
        for weakObject in weakObjects {
            if let object = weakObject.object as? T {
                function(object)
            }
        }
        weakObjects = weakObjects.filter { $0.object != nil }
    }

    /// Invoke event to instance that appended into
    /// - Parameter function: The callback foreach instance that you can invoke.
    /// The callback invoke on the main thread
    public func invokeMain(_ function: @escaping (T) -> ()) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.invoke(function)
            }
        )
    }
}

/// The fast way to implement Multicastable classes
/// Ex: class OrderManager: Multicastable {
///   typealias Events = OrderManagerEvent
///   var multicast = Multicast<OrderManagerEvent>
/// }
/// And outside can use orderManager.subscribeEvents(self)
public protocol Multicastable {

    associatedtype Events

    var multicast: Multicast<Events> { get }
}

public extension Multicastable {

    func subscribeEvents(_ subscriber: Events) {
        multicast.append(subscriber)
    }
    func unsubscribeEvents(_ subscriber: Events) {
        multicast.remove(subscriber)
    }
}
