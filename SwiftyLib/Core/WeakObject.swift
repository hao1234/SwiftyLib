//
//  WeakObject.swift
//  SwiftyLib
//
//  Created by Nguyen Vu Hao on 8/10/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

final public class WeakObject<T: AnyObject> {
    
    public weak var object: T?
    
    public init(object: T) {
        self.object = object
    }
}
