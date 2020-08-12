//
//  FIleClientProtocol.swift
//  BeePOS
//
//  Created by Andrew Eng on 5/9/16.
//  Copyright © 2016 Garena. All rights reserved.
//

import Foundation

public protocol FileClientEncryptionServiceProtocol {
    func encryptData(_ data: Data) -> Data
    func decryptData(_ data: Data) -> Data
}

public protocol FileClientProtocol {
    
    var encryptionService: FileClientEncryptionServiceProtocol { get }
    
    func write(data: Data, path: String, user: FileClient.User, directory: FileClient.Directory) throws
    func load(path: String, user: FileClient.User, directory: FileClient.Directory) throws -> Data?
    func delete(path: String, user: FileClient.User, directory: FileClient.Directory) throws

    func asyncWrite(data: Data, path: String, user: FileClient.User, directory: FileClient.Directory, completion: FileServiceCompletion?)
    func asyncLoad(path: String, user: FileClient.User, directory: FileClient.Directory, completion: FileServiceReadCompletion?)
    func asyncDelete(path: String, user: FileClient.User, directory: FileClient.Directory, completion: FileServiceCompletion?)
}

public extension FileClientProtocol {
    
    func write(data: Data, path: String, user: FileClient.User) throws {
        try write(data: data, path: path, user: user, directory: .document)
    }
    
    func load(path: String, user: FileClient.User) throws -> Data? {
        return try load(path: path, user: user, directory: .document)
    }
    
    func delete(path: String, user: FileClient.User) throws {
        return try delete(path: path, user: user, directory: .document)
    }

    func asyncWrite(data: Data, path: String, user: FileClient.User, completion: FileServiceCompletion?) {
        asyncWrite(data: data, path: path, user: user, directory: .document, completion: completion)
    }

    func asyncLoad(path: String, user: FileClient.User, completion: FileServiceReadCompletion?) {
        asyncLoad(path: path, user: user, directory: .document, completion: completion)
    }

    func asyncDelete(path: String, user: FileClient.User, completion: FileServiceCompletion?) {
        asyncDelete(path: path, user: user, directory: .document, completion: completion)
    }
}

// MARK: - FileClientProtocol+NSSecureCoding
public extension FileClientProtocol {
    
    func write<T: NSSecureCoding>(archive: T?, path: String, user: FileClient.User = .root, directory: FileClient.Directory = .document) throws {
        
        if let archive = archive {
            let data = try NSKeyedArchiver.safeArchiveObject(fromArchiver: archive)
            try write(data: data, path: path, user: user)
        } else {
            try delete(path: path, user: user)
        }
    }
    
    func loadArchive<T: NSSecureCoding>(path: String, user: FileClient.User = .root, directory: FileClient.Directory = .document) throws -> T? {
        
        let data = try load(path: path, user: user)
        if let data = data {
            return NSKeyedUnarchiver.safeUnarchiveObject(fromData: data)
        } else {
            return nil
        }
    }
}

public extension FileClientProtocol {
    func writeCodable<T: Codable>(codable: T?, path: String, user: FileClient.User = .root, directory: FileClient.Directory = .document) throws {

        if let codable = codable {
            let data = try JSONEncoder().encode(codable)
            try write(data: data, path: path, user: user)
        } else {
            try delete(path: path, user: user)
        }
    }

    func loadCodable<T: Codable>(path: String, user: FileClient.User = .root, directory: FileClient.Directory = .document) throws -> T? {

        let data = try load(path: path, user: user)
        if let data = data {
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            return nil
        }
    }
}

/// MARK: FileClientRequestableHandlerProtocol
public typealias FileClientRequestableLoadErrorBlock<T> = (_ error: Error?, _ data: T?) -> ()
public protocol FileClientRequestableHandlerProtocol {

    func writeSilent<RequestT: FileClientRequestable>(_ request: RequestT, completion: FileServiceCompletion?)
    func loadSilent<RequestT: FileClientRequestable>(_ request: RequestT, completion: FileClientRequestableLoadErrorBlock<RequestT.ModelT>?)
    func write<RequestT: FileClientRequestable>(_ request: RequestT) throws
    func load<RequestT: FileClientRequestable>(_ request: RequestT) throws -> RequestT.ModelT?
}

public extension FileClientRequestableHandlerProtocol {
    func writeSilent<RequestT: FileClientRequestable>(_ request: RequestT) {
        self.writeSilent(request, completion: nil)
    }

    func loadSilent<RequestT: FileClientRequestable>(_ request: RequestT) {
        self.loadSilent(request, completion: nil)
    }
}
