//
//  FileClientRequestableProtocol.swift
//  BPOSFoundation
//
//  Created by Andrew Eng on 31/3/17.
//  Copyright © 2017 Garena. All rights reserved.
//

import Foundation

/* Example usage if model conforms to NSSecureCoding:
 class <#Class#>: FileClientRequestable {
     var model: <#ModelClass#>?
     let path: String = "<#filePath#>"
     let user: FileClient.User = <#user#>
 }
 */

/// FileClientRequestable that supported to write an object into File
public protocol FileClientRequestable {
    
    associatedtype ModelT
    var model: ModelT? { get }
    
    var path: String { get }
    var user: FileClient.User { get }
    
    var directory: FileClient.Directory { get }
    var isEncrypted: Bool { get }
    
    func data(from model: ModelT) throws -> Data
    func model(from data: Data) throws -> ModelT?
}

public extension FileClientRequestable {
    var directory: FileClient.Directory { return .document }
    var isEncrypted: Bool { return false }
}

public extension FileClientRequestable where ModelT: NSSecureCoding {
    
    func data(from model: ModelT) throws -> Data {
        return try NSKeyedArchiver.safeArchiveObject(fromArchiver: model)
    }
    
    func model(from data: Data) throws -> ModelT? {
        return NSKeyedUnarchiver.safeUnarchiveObject(fromData: data)
    }
}

public extension FileClientRequestable where ModelT: Codable {

    func data(from model: ModelT) throws -> Data {
        return try JSONEncoder().encode(model)
    }

    func model(from data: Data) throws -> ModelT? {
        return try JSONDecoder().decode(ModelT.self, from: data)
    }
}

public typealias FileClientRequestableProtocol = FileClientProtocol & FileClientRequestable
