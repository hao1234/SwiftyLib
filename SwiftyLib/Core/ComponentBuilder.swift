//
//  ComponentBuilder.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/6/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

/// Protocol helper to build interface component in an easy and elegant way.
/*
Example
///  Regular usage:
///  let labelElement = LabelElement()
///  labelElement.style = .value3
///  labelElement.titleFont = Theme.current.fontPingFang(.normal, size: 14)
///  ...
///  rows.apppend(labelElement)
///
/// ComponentBuilder Usage:
/// let labelElement = LabelElement().build {
///      $0.style = .value3
///           $0.title = policy.title
/// }
///rows.apppend(labelElement)
///OR
/// rows.apppend(LabelElement().build {
///   $0.style = .value3
///   $0.title = policy.title
///   ...
///})
*/

public protocol ComponentBuilder {}

public extension ComponentBuilder where Self: Any {
    /// Calls the parameter block in order to update the receiver properties and then returns the object.
    func build(_ block: (Self) -> Void) -> Self {
        block(self)

        return self
    }
}

extension NSObject: ComponentBuilder {}
