//
//  Bundle+Additions.swift
//  SwiftyLib
//
//  Created by Nguyen Vu Hao on 8/12/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

/// The utitiliy methods to get common Bundle info
public extension Bundle {

    /// Get the BundleDisplayName or BundleName at Info.plst CFBundleDisplayName|CFBundleName.
    /// That use to get app name
    var name: String {
        if let displayName = infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
        }
        
        if let bundleName = infoDictionary?["CFBundleName"] as? String {
            return bundleName
        }
        
        assertionFailure()
        return ""
    }

    /// The the Bundle short version string at Info.plst CFBundleShortVersionString
    var version: String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
            assertionFailure();
            return ""
        }
        
        return version
    }

    /// Convert string bundle version to number version. The format is
    /// MajorVersion * 10000 + MinorVersion * 100 + PatchVersion
    /// Ex: 3.4.5 => 30405, 30.5.10 => 300510
    var versionValue: UInt32 {
        var components = version.split(separator: ".").compactMap { UInt32(String($0)) }
        
        if components.count < 3 {
            // Append zeros if needed
            (0..<(3 - components.count)).forEach { (_) in
                components.append(0)
            }
        }
        
        let value = components[0] * 10000 + components[1] * 100 + components[2]
        
        if components.count != 3 {
            assertionFailure();
        }
        
        return value
    }

    /// Get bundle id from Info.plist at CFBundleIdentifier
    var bundleIdentifier: String {
        guard let identifier = infoDictionary?["CFBundleIdentifier"] as? String else {
            assertionFailure();
            return ""
        }
        
        return identifier
    }

    /// Get bundle build version from Info.plist at CFBundleVersion
    var buildVersionNumber: String {
        guard let buildVersionNumber = infoDictionary?["CFBundleVersion"] as? String else {
            assertionFailure();
            return ""
        }

        return buildVersionNumber
    }
}
