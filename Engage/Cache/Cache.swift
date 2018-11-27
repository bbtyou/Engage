//
//  Cache.swift
//  Engage
//
//  Created by Charles Imperato on 11/18/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// - Enum describing the different cache configurations
public enum CacheConfiguration: Int {
    case memory
    case disk
}

public typealias CacheResult<T: Codable> = (_ item: T?) -> ()

// - This protocol defines caching implementations
public protocol Cache {
    associatedtype T: Codable
    
    // - Sets a value in the cache
    func set(_ item: T, forKey key: String)
    
    // - Removes an item from the cache
    func remove(forKey key: String)
    
    // - Retrieves an item from the cache
    func item(forKey key: String, _ result: @escaping CacheResult<T>)
    
    // - Returns true if a cached item exists for the specified key
    func cached(forKey key: String) -> Bool
    
    // - Clears the entire cache
    func clear()
    
}

// MARK: - DefaultCache

public class DefaultCache<T: Codable> {
    
    // - Memory cache using NSCache
    fileprivate var memory: NSCache<NSString, MemoryCacheWrapper>?
    
    // - Disk cache
    fileprivate var disk: DiskCache<T>?
    
    public init(name: String, _ configurations: [CacheConfiguration] = [.disk, .memory], _ capacity: UInt64 = UINT64_MAX, _ totalCost: Int = 200 * 1000 * 1000) {
        // - Create disk cache
        if configurations.contains(.disk) {
            do {
                // - Attempt to create the disk cache
                self.disk = try DiskCache.init(name: name, capacity: capacity)
            }
            catch {
                log.error("The disk cache could not be create. \(error)")
            }
        }
        
        // - Create memory cache
        if configurations.contains(.memory) || configurations.count == 0 {
            self.memory = NSCache<NSString, MemoryCacheWrapper>()
            self.memory?.totalCostLimit = totalCost
        }
    }
    
    // - Wrapper methods for NSCache for convenience
    fileprivate func setCacheMemory(_ object: Any, forKey key: String) {
        self.memory?.setObject(MemoryCacheWrapper.init(object), forKey: NSString.init(string: key))
    }
    
    fileprivate func removeCacheMemory(forKey key: String) {
        self.memory?.removeObject(forKey: NSString.init(string: key))
    }
}

// MARK: Cache

extension DefaultCache: Cache {
    
    public func set(_ item: T, forKey key: String) {
        self.setCacheMemory(item, forKey: key)
        self.disk?.set(item, forKey: key)
    }
    
    public func remove(forKey key: String) {
        self.removeCacheMemory(forKey: key)
        self.disk?.remove(forKey: key)
    }
    
    public func item(forKey key: String, _ result: @escaping (T?) -> ()) {
        if let item = self.memory?.object(forKey: NSString.init(string: key))?.item as? T {
            result(item)
            self.disk?.updateAccessDate(forKey: key)
            return
        }
        
        self.disk?.item(forKey: key, { (item) in
            if let item = item {
                self.disk?.updateAccessDate(forKey: key)
                self.setCacheMemory(item, forKey: key)
            }
            
            result(item)
        })
    }
    
    public func cached(forKey key: String) -> Bool {
        if let _ = self.memory?.object(forKey: NSString.init(string: key)) {
            self.disk?.updateAccessDate(forKey: key)
            return true
        }
        
        if let reachable = self.disk?.fileExists(forKey: key), reachable == true {
            self.disk?.item(forKey: key, { (item) in
                if let result = item {
                    self.setCacheMemory(result, forKey: key)
                }
            })
            
            return true
        }
        
        return false
    }
    
    public func clear() {
        self.memory?.removeAllObjects()
        self.disk?.clear()
    }
}

// MARK: - Private

// - This wrapper enables the NSCache to consume objects that are Codable
fileprivate class MemoryCacheWrapper {
    
    // - The cacheable item
    fileprivate let item: Any
    
    public init(_ item: Any) {
        self.item = item
    }
    
}
