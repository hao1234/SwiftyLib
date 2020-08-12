//
//  ElementModel.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/10/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import UIKit

public protocol ElementModel {
    func cellClass() -> AnyClass!
    func selected()
    func indentifer() -> String
    func cell(for tableView: UITableView!, indexPath: IndexPath) -> UITableViewCell
    func addAction(_ actionBlock: @escaping TapElementBlock)
}
