//
//  SharedCache.swift
//  Engage
//
//  Created by Charles Imperato on 11/18/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

struct Shared {
    
    static var imagesCache : DefaultCache<CodableImage> {
        struct Static {
            static let name = "shared-images"
            static let cache = DefaultCache<CodableImage>.init(name: name)
        }
        
        return Static.cache
    }
    
    static var dataCache: DefaultCache<CodableData> {
        struct Static {
            static let name = "shared-data" 
            static let cache = DefaultCache<CodableData>.init(name: name, [.disk])
        }
        
        return Static.cache
    }
    
}
