//
//  Element.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/10/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import UIKit

public typealias TapElementBlock = (_ element: Element) -> Void
open class Element: NSObject, ElementModel {
    
    public var hasNextPage = false
    private var actionBlock: TapElementBlock?
    
    public func cellClass() -> AnyClass! {
        BaseTableViewCell.self
    }
    
    public func addAction(_ actionBlock: @escaping TapElementBlock) {
        self.actionBlock = actionBlock
    }
    
    public func selected() {
        actionBlock?(self)
    }
    
    public func indentifer() -> String {
        String(describing: cellClass().self)
    }
    
    public func cell(for tableView: UITableView!, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(cellClass(), forCellReuseIdentifier: indentifer())
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: indentifer(),
            for: indexPath) as? BaseTableViewCell {
            configCell(cell: cell)
        }
        
        return UITableViewCell()
    }
    
    private func configCell(cell: BaseTableViewCell) {
        cell.accessoryType = .none
        if hasNextPage {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryView = nil
        }
    }
}
