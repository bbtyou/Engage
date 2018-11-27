//
//  AssetFileDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/20/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class AssetFileDataSource: RestResponseCheckable {
    
    func fetchAsset(fromModel file: File, _ result: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        // - Download and cache if necessary
        let request = DownloadRequest.init(path: file.url)
        
        // - Check if this item is in the cache
        let cache = Shared.dataCache
        
        cache.item(forKey: request.fullPath) { (codableData) in
            if let data = codableData?.data {
                DispatchQueue.main.async {
                    result(data, nil)
                }
                
                return
            }
            
            // - Download the data if it is not cached
            request.sendRequest { (response, data, error) in
                if let err = self.checkResponse(response, data, error) {
                    result(nil, err)
                    return
                }
                
                result(data!, nil)
            }
        }
    }
}
