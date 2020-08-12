//
//  UIView+Additions.swift
//  SwiftyLib
//
//  Created by Nguyen Vu Hao on 8/12/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import UIKit

// MARK: - Auto layouts
extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        views.forEach {
            addSubview($0)
        }
    }
    
    public func increaseDefaultHorizontalCompressionResistanceAndHuggingPriority(by value: Float = 100) {
        setContentHuggingPriority(UILayoutPriority(rawValue: 250 + value), for: .horizontal)
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750 + value), for: .horizontal)
    }
    
    public func increaseDefaultVerticalCompressionResistanceAndHuggingPriority(by value: Float = 100) {
        setContentHuggingPriority(UILayoutPriority(rawValue: 250 + value), for: .vertical)
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750 + value), for: .vertical)
    }
    
    public func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        
        for subview in subviews {
            
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(
                    withVisualFormat: $0,
                    options: [],
                    metrics: ["inset": inset, "thickness": thickness],
                    views: ["border": border]) })
            borders.append(border)
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
}
