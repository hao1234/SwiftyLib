//
//  FileService.swift
//  SeaFoundation
//
//  Created by Thanh Quach on 12/27/18.
//  Copyright © 2018 Sea Ltd. All rights reserved.
//

import Foundation

public typealias FileServiceCompletion = (_ error: Error?) -> ()
public typealias FileServiceReadCompletion = (_ data: Data?, _ error: Error?) -> ()

/// The low level class to access file by using FileManager(Foundation)
open class FileService {

    /// The singleton instance
    public static let shared: FileService = FileService()
    //Concurrent queue to allow single writer and multiple reads
    private let fileQueue: DispatchQueue

    /// The base directory of FileService
    public var directory: String?

    public init() {
        self.fileQueue = DispatchQueue(label: "com.seafoundation.filesystem.write", attributes: .concurrent)
    }

    public convenience init(directory: String?) {
        self.init()
        self.directory = directory
    }

    public func directory(forPath path: String) -> String {
        guard let directory = directory else {
            return path
        }

        return URL(fileURLWithPath: directory).appendingPathComponent(path).absoluteString
    }

    public var baseDocumentDirectory: String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }

    public var baseCacheDirectory:  String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    public var baseLibraryDirectory: String? {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
    }
    
    public var baseSoundsDirectory: String? {
        guard let soundsDirectory = libraryPath("Sounds") else {
            return nil
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: soundsDirectory) {
            do {
                try fileManager.createDirectory(atPath: soundsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        
        return soundsDirectory
    }

    public var documentDirectory: String? {
        guard let directory = directory else {
            return baseDocumentDirectory
        }
        return (baseDocumentDirectory as NSString?)?.appendingPathComponent(directory)
    }

    public var cacheDirectory: String? {
        guard let directory = directory else {
            return baseCacheDirectory
        }

        return (baseCacheDirectory as NSString?)?.appendingPathComponent(directory)
    }

    public var libraryDirectory: String? {
        guard let directory = directory else {
            return baseLibraryDirectory
        }
        
        return (baseLibraryDirectory as NSString?)?.appendingPathComponent(directory)
    }
    
    public var soundsDirectory: String? {
        guard let directory = directory else {
            return baseSoundsDirectory
        }
        
        return (baseSoundsDirectory as NSString?)?.appendingPathComponent(directory)
    }
    
    public func documentPath(_ path: String) -> String? {
        return (self.documentDirectory as NSString?)?.appendingPathComponent(path)
    }

    public func cachePath(_ path: String) -> String? {
        return (self.cacheDirectory as NSString?)?.appendingPathComponent(path)
    }
    
    public func libraryPath(_ path: String) -> String? {
        return (self.libraryDirectory as NSString?)?.appendingPathComponent(path)
    }
    
    public func soundsPath(_ path: String) -> String? {
        return (self.soundsDirectory as NSString?)?.appendingPathComponent(path)
    }

    /// Sync writing
    /// - Parameter path: The path to append to basePath
    /// - Parameter content: The content to write
    public func write(toPath path: String, data content: Data?) -> Bool {
        var success: Bool = false
        fileQueue.sync(flags: .barrier) {
            success = self.syncWrite(toFile: path, data: content)
        }
        return success
    }

    /// Sync writing. Write to new file, or append to existing file
    /// - Parameter path: The path to append to basePath
    /// - Parameter content: The content to write
    public func writeAppend(toPath path: String, data content: Data?) -> Bool {
        var success = false
        fileQueue.sync(flags: .barrier) {
            if !(FileManager.default.fileExists(atPath: path)) {
                success = self.syncWrite(toFile: path, data: content)
            } else {
                autoreleasepool {
                    guard let fHandle = FileHandle(forWritingAtPath: path),
                        let content = content
                    else {
                        return
                    }
                    success = true
                    fHandle.seekToEndOfFile()
                    fHandle.write(content)
                    fHandle.closeFile()
                }
            }
        }
        return success
    }

    /// AsSync writing
    /// - Parameter path: The path to append to basePath
    /// - Parameter content: The content to write
    public func scheduleWrite(toPath path: String, data content: Data, completion: FileServiceCompletion?) {
        fileQueue.async(flags: .barrier)  {
            let success = self.syncWrite(toFile: path, data: content)
            var error: Error?
            if !success {
                error = NSError(domain: "com.btfoundation.fileservice", code: 99, userInfo: nil)
            }
            completion?(error)
        }
    }

    /// Sync reading
    /// - Parameter path: The path to append to basePath
    /// - Return the data loaded
    public func load(fromPath path: String) -> Data? {
        var data: Data?
        fileQueue.sync(execute: {
            data = NSData(contentsOfFile: path) as Data?
        })

        return data
    }

    /// Async reading
    /// - Parameter path: The path to append to basePath
    /// - Return the data loaded
    public func load(fromPath path: String, completion: FileServiceReadCompletion?) {
        fileQueue.async {
            let data = NSData(contentsOfFile: path) as Data?
            completion?(data, nil)
        }
    }

    /// Sync deleting
    /// - Parameter path: The path to append to basePath
    /// - Return the boolean succecced
    public func delete(fromPath path: String) -> Bool {
        var error: Error?
        fileQueue.sync(flags: .barrier) {
            error = self.syncDelete(fromPath: path)
        }

        return error == nil
    }

    /// Async deleting
    /// - Parameter path: The path to append to basePath
    /// - Return the boolean succecced
    public func delete(fromPath path: String, completion: FileServiceCompletion?) {
        fileQueue.async(flags: .barrier) {
            let error: Error? = self.syncDelete(fromPath: path)
            completion?(error)
        }
    }

    // MARK: - Private methods
    private func syncWrite(toFile path: String, data content: Data?) -> Bool {
        //If no content, we try to delete the path
        guard let content = content else {
            let error = syncDelete(fromPath: path)
            return error == nil
        }

        let urlWithoutFile = URL(fileURLWithPath: path).deletingLastPathComponent()
        let directoryExists: Bool = FileManager.default.fileExists(atPath: urlWithoutFile.absoluteString)

        if !directoryExists {
            do {
                try FileManager.default.createDirectory(at: urlWithoutFile, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                assert(false, "Error writing to file.Unable to create directory:\(error)")
                return false
            }
        }
        do {
            try content.write(to: URL(fileURLWithPath: path), options: .atomicWrite)
            return true
        } catch let error {
            assert(false, "Error writing to file.Unable to write to path: \(path) withError:\(error)")
            return false
        }
    }

    private func syncDelete(fromPath path: String) -> Error? {
        do {
            try FileManager.default.removeItem(atPath: path)
            return nil
        } catch let error {
            print("Error deletingPath:\(path) error:\(error)")
            return error
        }
    }
}
