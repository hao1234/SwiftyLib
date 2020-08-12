//
//  FileClient.swift
//  BeePOS
//
//  Created by Andrew Eng on 21/6/16.
//  Copyright © 2016 Garena. All rights reserved.
//

import Foundation

/// The FileClient that support us to work with file more than easier
open class FileClient: FileClientProtocol, FileClientRequestableHandlerProtocol {
    
    public enum User {
        case root
        case chain
        case shop
        case user
    }
    
    public enum Directory {
        case document
        case cache
        case library
        case sounds
    }
    
    public struct UserInfo {
        let shopPath: String
        let userPath: String
        
        public init(shopPath: String, userPath: String) {
            self.shopPath = shopPath
            self.userPath = userPath
        }
    }
    
    public var chainPath: String?
    public var userInfo: UserInfo?
    
    public let encryptionService: FileClientEncryptionServiceProtocol
    private let fileService: FileService
    
    public init(fileService: FileService,
                encryptionService: FileClientEncryptionServiceProtocol) {
        self.fileService = fileService
        self.encryptionService = encryptionService
    }
}

public extension FileClient {
    
    func write(data: Data, path: String, user: User = .root, directory: Directory = .document) throws {
        
        let absolutePath = try constructAbsolutePath(path, user: user, directory: directory)
        
        let success = fileService.write(toPath: absolutePath, data: data)
            
        if !success {
            let msg = "path: \(path), data.length: \(data.count)"
            throw FileClientError.writeFailed(msg)
        }
    }
    
    func load(path: String, user: User = .root, directory: Directory = .document) throws -> Data? {

        let absolutePath = try constructAbsolutePath(path, user: user, directory: directory)
        
        let data = fileService.load(fromPath: absolutePath) as Data?
        
        return data
    }
    
    func delete(path: String, user: User = .root, directory: Directory = .document) throws {
        
        let absolutePath = try constructAbsolutePath(path, user: user, directory: directory)
        
        if !fileService.delete(fromPath: absolutePath) {
            throw FileClientError.unknown("Delete failure")
        }
    }

    func asyncWrite(data: Data, path: String, user: FileClient.User = .root, directory: FileClient.Directory = .document, completion: FileServiceCompletion?) {
        do {
            let absolutePath = try constructAbsolutePath(path, user: user, directory: directory)
            fileService.scheduleWrite(toPath: absolutePath, data: data, completion: completion)
        } catch let error {
            completion?(error)
        }
    }

    func asyncLoad(path: String, user: FileClient.User = .root, directory: FileClient.Directory = .document, completion: FileServiceReadCompletion?) {
        do {
            let absolutePath = try constructAbsolutePath(path, user: user, directory: directory)
            fileService.load(fromPath: absolutePath, completion: completion)
        } catch let error {
            completion?(nil, error)
        }
    }

    func asyncDelete(path: String, user: FileClient.User = .root, directory: FileClient.Directory = .document, completion: FileServiceCompletion?) {
        do {
            let absolutePath = try constructAbsolutePath(path, user: user, directory: directory)
            fileService.delete(fromPath: absolutePath, completion: completion)
        } catch let error {
            completion?(error)
        }
    }
}

// MARK: - FileClientRequestableHandlerProtocol
public extension FileClient {

    func writeSilent<RequestT: FileClientRequestable>(_ request: RequestT, completion: FileServiceCompletion?) {
        do {
            guard let model = request.model else {
                try delete(path: request.path, user: request.user, directory: request.directory)
                return
            }

            var data = try request.data(from: model)

            if request.isEncrypted {
                data = encryptionService.encryptData(data)
            }
            asyncWrite(data: data, path: request.path, user: request.user, directory: request.directory, completion: completion)
        } catch let error {
            completion?(error)
        }
    }

    func loadSilent<RequestT: FileClientRequestable>(_ request: RequestT, completion: FileClientRequestableLoadErrorBlock<RequestT.ModelT>?) {
        do {
            guard var data = try load(path: request.path, user: request.user, directory: request.directory) else {
                completion?(FileClientError.writeFailed("Data not exits at request path info \(request)"), nil)
                return
            }

            if request.isEncrypted {
                data = encryptionService.decryptData(data)
            }

            guard let model = try request.model(from: data) else {
                let error = FileClientError.unknown("Failed to convert model: \(RequestT.ModelT.self), from data: \(data)")
                completion?(error, nil)
                return
            }

            completion?(nil, model)
        } catch let error {
            completion?(error, nil)
        }
    }

    func write<RequestT: FileClientRequestable>(_ request: RequestT) throws {

        guard let model = request.model else {
            try delete(path: request.path, user: request.user, directory: request.directory)
            return
        }

       var data = try request.data(from: model)

        if request.isEncrypted {
            data = encryptionService.encryptData(data)
        }

        try write(data: data, path: request.path, user: request.user, directory: request.directory)
    }

    func load<RequestT: FileClientRequestable>(_ request: RequestT) throws -> RequestT.ModelT? {

        guard var data = try load(path: request.path, user: request.user, directory: request.directory) else {
            return nil
        }

        if request.isEncrypted {
            data = encryptionService.decryptData(data)
        }

        guard let model = try request.model(from: data) else {
            throw FileClientError.unknown("Failed to convert model: \(RequestT.ModelT.self), from data: \(data)")
        }

        return model
    }
}

// Path
extension FileClient {

    fileprivate func constructAbsolutePath(_ path: String, user: User, directory: Directory) throws -> String {

        let relativePath = try constructUserPath(path, user: user)
        return try constructAbsolutePath(relativePath, directory: directory)
    }

    fileprivate func constructUserPath(_ path: String, user: User) throws -> String {

        switch user {

        case .root:
            return path

        case .chain:
            guard let chainPath = chainPath else {
                throw FileClientError.emptyChainInfo
            }

            return chainPath + "/" + path

        case .shop:

            guard let userInfo = userInfo else {
                throw FileClientError.emptyUserInfo
            }

            return userInfo.shopPath + "/" + path

        case .user:

            guard let userInfo = userInfo else {
                throw FileClientError.emptyUserInfo
            }

            return userInfo.shopPath + "/" + userInfo.userPath + "/" + path
        }
    }

    fileprivate func constructAbsolutePath(_ path: String, directory: Directory) throws -> String {

        switch directory {
        case .document:
            guard let absolutePath = fileService.documentPath(path) else {
                throw FileClientError.unknown("Empty documentPathForPath: \(path)")
            }
            return absolutePath
        case .cache:
            guard let absolutePath = fileService.cachePath(path) else {
                throw FileClientError.unknown("Empty cachePathForPath: \(path)")
            }
            return absolutePath
        case .library:
            guard let absolutePath = fileService.libraryPath(path) else {
                throw FileClientError.unknown("Empty libraryPathForPath: \(path)")
            }
            return absolutePath
        case .sounds:
            guard let absolutePath = fileService.soundsPath(path) else {
                throw FileClientError.unknown("Empty soundsPathForPath: \(path)")
            }
            return absolutePath
        }
    }
}
