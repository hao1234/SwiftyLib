//
//  AdapterDatasource.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/6/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import UIKit

open class AdapterDatasource: NSObject {
    public let sections: [SectionModelProtocol]
    public var shouldAutoDeselectRowAfterSelection = true
    public var defaultPaddingSection: CGFloat = 25
    
    public init(sections: [SectionModelProtocol]) {
        self.sections = sections
    }
}

extension AdapterDatasource: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < sections.count else {
            return UITableViewCell()
        }
        let section = sections[indexPath.section]
        
        guard indexPath.row < section.rows.count else {
            return UITableViewCell()
        }
        
        let element = section.rows[indexPath.row]
        return element.cell(for: tableView, indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < sections.count else {
            return
        }
        let section = sections[indexPath.section]
        
        section.rows[indexPath.row].selected()
        if shouldAutoDeselectRowAfterSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < sections.count else {
            return .leastNonzeroMagnitude
        }
        let section = sections[section]
        return section.headerView?.frame.size.height ?? .leastNonzeroMagnitude
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < sections.count else {
            return nil
        }
        let section = sections[section]
        return section.headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < sections.count else {
            return .leastNonzeroMagnitude
        }
        let section = sections[section]
        return section.footerView?.frame.size.height ??
            section.bottomPadding == -1
            ? defaultPaddingSection
            : section.bottomPadding
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < sections.count else {
            return nil
        }
        let section = sections[section]
        return section.footerView
    }
}
