//
//  BaseTableViewCell.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/10/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import UIKit

open class BaseTableViewCell: UITableViewCell {
    
    private var borderBottom: UIView?
    private var borderTop: UIView?
    
    public var showTopBorder: Bool = false {
        didSet {
            borderTop?.isHidden = !showTopBorder
        }
    }
    public var showBottomBorder: Bool = false {
        didSet {
            borderBottom?.isHidden = !showBottomBorder
        }
    }
    public var borderColor = UIColor.lightGray {
        didSet {
            borderTop?.backgroundColor = borderColor
            borderBottom?.backgroundColor = borderColor
        }
    }
    public var borderThickness: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }
    public var bottomBorderInset: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    public var bottomBorderRightPadding: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    public var topBorderLeftPadding: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    public var topBorderRightPadding: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        borderTop?.frame = CGRect(
            x: topBorderLeftPadding,
            y: borderThickness/2,
            width: self.bounds.size.width - topBorderLeftPadding - topBorderRightPadding,
            height: borderThickness)
        borderBottom?.frame = CGRect(
            x: topBorderLeftPadding,
            y: self.bounds.size.height - borderThickness,
            width: self.bounds.size.width - topBorderLeftPadding - topBorderRightPadding,
            height: borderThickness)
        reconfigureConstraint()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
        configureView()
        configureConstraint()
    }
    
    public override func prepareForReuse() {
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureView() {
        // Override to add subview
    }
    
    public func configureConstraint() {
        // Override to add constraint
    }
    
    public func reconfigureConstraint() {
        // Override to update constraint
    }
    
    private func commonInit() {
        addBorder()
    }
    
    private func addBorder() {
        borderBottom = addBorders(
            edges: .bottom,
            color: borderColor,
            inset: .zero,
            thickness: borderThickness).first
        borderTop = addBorders(
            edges: .top,
            color: borderColor,
            inset: .zero,
            thickness: borderThickness).first
    }
}
