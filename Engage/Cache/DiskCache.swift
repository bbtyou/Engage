//
//  DiskCache.swift
//  Engage
//
//  Created by Charles Imperato on 11/18/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

import Foundation

// - This class handles the caching to disk using an LRU strategy
class DiskCache<T: Codable> {
    
    // - Cache path directory
    fileprivate var cachePath: String {
        get {
            let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let cacheDirectory = self.name
            let path = cachesPath + "/\(cacheDirectory)"
            
            return path
        }
    }
    
    // - Cache name to be used as the directory name under the caches directory
    let name: String
    
    // - Cache queue for handling cache operations in a thread safe manner
    
    // - Cache queue for backgrounded operations
    lazy var cacheQueue: DispatchQueue = {
        return DispatchQueue.init(label: "com.diskCache.\(self.name)", attributes: .concurrent)
    }()
    
    // - Cache capacity defaulting UINT64_MAX
    var capacity: UInt64 = 0 {
        didSet {
            self.cacheQueue.async(flags: .barrier) {
                self.prune()
            }
        }
    }
    
    // - The size of the cache
    fileprivate var size: UInt64 = 0
    
    init(name: String, capacity: UInt64 = UINT64_MAX) throws {
        self.name = name
        self.capacity = capacity
        
        // - Create the directory
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: self.cachePath, withIntermediateDirectories: true, attributes: nil)
        
        self.calculateSize()
    }
    
    // - Updates the access date for the file to the current date
    func updateAccessDate(forKey key: String) {
        let fileName = self.filePath(fromKey: key)
        
        // Update the access time of the file
        let fileManager = FileManager.default
        
        do {
            // - Update the modification date to the current date/time
            try fileManager.setAttributes([FileAttributeKey.modificationDate: Date()], ofItemAtPath: fileName)
        }
        catch {
            log.error("The file item was retrieved but the access time could not be updated. \(error)")
        }
    }
    
    // - Checks if the file exists
    func fileExists(forKey key: String) -> Bool {
        let fileName = self.filePath(fromKey: key)
        
        do {
            // - Check if the resource is reachable
            return try URL.init(fileURLWithPath: fileName).checkResourceIsReachable()
        }
        catch {
            log.error(error.localizedDescription)
        }
        
        return false
    }
    
    // MARK: - Private
    
    // - Create the filepath from the key
    fileprivate func filePath(fromKey key: String) -> String {
        if let digest = key.data(using: .utf8)?.SHA256Digest {
            return "\(self.cachePath)/\(digest).dat"
        }
        
        return key
    }
    
    fileprivate func calculateSize() {
        let fileManager = FileManager.default
        
        self.size = 0
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: self.cachePath)
            files.forEach { (file) in
                let filePath = self.cachePath + "/\(file)"
                
                do {
                    // - Get the file size and subtract from total size
                    let attributes = try fileManager.attributesOfItem(atPath: filePath)
                    if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                        self.size += fileSize
                    }
                    
                }
                catch {
                    log.error("The file attributes could not be retrieved to calculate the size. \(error.localizedDescription)")
                }
            }
        }
        catch {
            log.error("Unable to get contents of the directory")
        }
    }
    
    // - Keeps the cache size within the specified capacity by removing the least recently used
    fileprivate func prune() {
        if self.size <= self.capacity {
            return
        }
        
        let fileManager = FileManager.default
        var sorted = fileManager.contents(forPath: self.cachePath, .modificationDate, sortAscending: true)
        
        // - Remove items until the size is under capacity
        while self.size > self.capacity {
            if let oldestFile = sorted.last {
                self.removeFile(atPath: oldestFile)
                sorted.removeLast()
            }
        }
    }
    
    @discardableResult fileprivate func addFile(atPath path: String, _ contents: Data) -> Bool {
        let fileManager = FileManager.default
        
        // - If the file exists remove it before creating the new file
        if fileManager.fileExists(atPath: path) {
            self.removeFile(atPath: path)
        }
        
        let result = fileManager.createFile(atPath: path, contents: contents, attributes: nil)
        if result {
            if let attrs = try? fileManager.attributesOfItem(atPath: path), let size = attrs[FileAttributeKey.size] as? UInt64 {
                self.size += size
                self.prune()
            }
        }
        else {
            log.error("File for path = \(path) could not be added to the disk cache.")
        }

        return result
    }
    
    @discardableResult fileprivate func removeFile(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        
        do {
            // - Get the size of the item to be removed
            let fileAttr = try fileManager.attributesOfItem(atPath: path)
            if let size = fileAttr[FileAttributeKey.size] as? UInt64 {
                self.size -= size
                
                // - Remove the item
                try fileManager.removeItem(atPath: path)
                
                // - Success
                return true
            }
        }
        catch {
            log.error("The file at path = \(path) could not be removed from the disk cache. \(error)")
        }
        
        return false
    }
}

// MARK: - Cache

extension DiskCache: Cache {
    func cached(forKey key: String) -> Bool {
        var exists = false
        
        self.cacheQueue.sync {
            exists = self.fileExists(forKey: key)
            if exists {
                self.updateAccessDate(forKey: key)
            }
        }
        
        return exists
    }
    
    func set(_ item: T, forKey key: String) {
        self.cacheQueue.async(flags: .barrier) {
            let encoder = JSONEncoder()
            
            do {
                // - Attempt to encode the item and store it in a file
                let data = try encoder.encode(item)
                self.addFile(atPath: self.filePath(fromKey: key), data)
            }
            catch {
                log.error("Unable to add the item to the cache with key = \(key). \(error)")
            }
        }
    }
    
    func remove(forKey key: String) {
        self.cacheQueue.async(flags: .barrier) {
            self.removeFile(atPath: self.filePath(fromKey: key))
        }
    }
    
    func item(forKey key: String, _ result: @escaping (T?) -> ()) {
        self.cacheQueue.async {
            var item: T?
            
            let fileName = self.filePath(fromKey: key)
            
            do {
                // - Get the contents of the file
                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: fileName))
                let decoder = JSONDecoder()
                
                item = try decoder.decode(T.self, from: data)
                self.updateAccessDate(forKey: key)
            }
            catch {
                log.error("The item was unable to be decoded from the disk cache. \(error)")
            }
            
            result(item)
        }
    }
    
    func clear() {
        let fileManager = FileManager.default
        
        self.cacheQueue.async(flags: .barrier) {
            do {
                let files = try fileManager.contentsOfDirectory(atPath: self.cachePath)
                files.map({ (file) -> String in
                    return self.cachePath + "/\(file)"
                    
                }).forEach({ (filePath) in
                    do {
                        // - Attempt to remove the file
                        try fileManager.removeItem(atPath: filePath)
                    }
                    catch {
                        log.error("Unable to remove file from path \(filePath). \(error)")
                    }
                })
                
            }
            catch {
                log.error("Unable to clear the disk cache. \(error).")
            }
        }
    }
    
}
