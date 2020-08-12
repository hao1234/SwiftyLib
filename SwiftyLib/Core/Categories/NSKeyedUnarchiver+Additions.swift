//
//  NSKeyedUnarchiver+Additions.swift
//  SwiftyLib
//
//  Created by Nguyen Vu Hao on 8/12/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

/// The supporter to Unarchiver object to model generic
public extension NSKeyedUnarchiver {
    /// UnarchiveObject from data and return generic  ModelT that confirm NSSecureCoding
    /// - Parameter data: The ModelT result
    static func safeUnarchiveObject<ModelT: NSSecureCoding>(fromData data: Data) -> ModelT? {
        if #available(iOS 12, *) {
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClasses: [ModelT.self], from: data) as? ModelT
            } catch let error {
                print("UnarchiveObject: \(ModelT.self) failure withError: \(error)")
                return nil
            }
        } else {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? ModelT
        }
    }

    /// UnarchiveObject from data and return generic Array ModelT that confirm NSSecureCoding
    /// - Parameter data: The array ModelT result
    static func safeUnarchiveObjects<ModelT: NSSecureCoding>(fromData data: Data) -> [ModelT]? {
        if #available(iOS 12, *) {
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClasses: [ModelT.self, NSArray.self], from: data) as? [ModelT]
            } catch let error {
                print("UnarchiveObject: \(ModelT.self) failure withError: \(error)")
                return nil
            }
        } else {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [ModelT]
        }
    }
}

/// The supporter to Archiver object to model generic
public extension NSKeyedArchiver {

    /// ArchiveObject ModelT that confirm NSSecureCoding
    /// - Parameter archiver: The return data after archive
    static func safeArchiveObject<ModelT: NSSecureCoding>(fromArchiver archiver: ModelT) throws -> Data {
        return try self.safeArchiveObject(archiver, requiringSecureCoding: ModelT.supportsSecureCoding)
    }

    /// ArchiveObject Array ModelT that confirm NSSecureCoding
    /// - Parameter archiver: The return data after archive
    static func safeArchiveObjects<ModelT: NSSecureCoding>(fromArchivers archivers: [ModelT]) throws -> Data {
        return try self.safeArchiveObject(archivers, requiringSecureCoding: ModelT.supportsSecureCoding)
    }

    private static func safeArchiveObject(_ object: Any, requiringSecureCoding: Bool) throws -> Data {
        var dataSaving: Data
        if #available(iOS 11.0, *) {
            dataSaving = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: requiringSecureCoding)
        } else {
            dataSaving = NSKeyedArchiver.archivedData(withRootObject: object)
        }

        return dataSaving
    }
}
