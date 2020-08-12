//
//  String+Additions.swift
//  SwiftyLib
//
//  Created by Nguyen Vu Hao on 8/12/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

public extension String {
    
    /**
     Returns a new string by removing string prefix.
     - Parameter prefix: Prefix to be removed.
     - See `removePrefix(_:)`
     */
    func removingPrefix(_ prefix: String) -> String {
        var result = self
        result.removePrefix(prefix)
        return result
    }
    
    /**
     Removes string prefix.
     - Parameter prefix: Prefix to be removed.
     - Precondition: Current string must contain specified prefix.
     */
    mutating func removePrefix(_ prefix: String) {
        precondition(hasPrefix(prefix))
        removeSubrange(prefix.startIndex..<prefix.endIndex)
    }

    /**
     Check string is email
    */
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,40}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

}

extension String {
    static func randomString(limit: UInt? = nil) -> String {
        let uuidString = UUID().uuidString
        if let limit = limit {
            return String(uuidString.prefix(Int(limit)))
        }

        return uuidString
    }
}

extension StringProtocol {
    
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }

    var firstCapitalized: String {
        guard let first = first else { return "" }
        return String(first).capitalized + dropFirst()
    }
}
