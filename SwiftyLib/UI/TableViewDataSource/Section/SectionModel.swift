//
//  SectionModel.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/10/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import UIKit

open class SectionModel: SectionModelProtocol {
    
    public var headerView: UIView?
    public var footerView: UIView?
    public var bottomPadding: CGFloat = -1

    public var rows: [ElementModel] = []
    
    public init(rows: [ElementModel] = []) {
        self.rows = rows
    }
    
    public var count: Int {
        return rows.count
    }
    
    public func cellClass(at: Int) -> AnyClass! {
        rows[at].cellClass()
    }
}
