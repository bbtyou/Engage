//
//  Cacheable.swift
//  Engage
//
//  Created by Charles Imperato on 11/15/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

// - Protocol defining a cacheable item
protocol Cacheable {
    
    // - Writes the data to the cache
    func write(_ data: Data)
    
    
}

// Mark: - ImageRequestCacheable
extension Cacheable where Self == ImageRequest {
    
    func write(_ data: Data) {
        let cache = Shared.imagesCache
        
        if let image = UIImage.init(data: data) {
            cache.set(CodableImage.init(image: image), forKey: self.fullPath)
        }
    }
    
}

// MARK: - DataCacheable

extension Cacheable where Self == DownloadRequest {
    
    func write(_ data: Data) {
        let cache = Shared.dataCache
        cache.set(CodableData.init(data: data), forKey: self.fullPath)
    }
        
}
