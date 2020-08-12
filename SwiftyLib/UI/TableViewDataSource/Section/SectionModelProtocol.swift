//
//  SectionModelProtocol.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/10/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import UIKit

public protocol SectionModelProtocol {
    var count: Int { get }
    var rows: [ElementModel] { get }
    var headerView: UIView? { get set }
    var footerView: UIView? { get set }
    var bottomPadding: CGFloat { get set }
    
    func cellClass(at: Int) -> AnyClass!
}
