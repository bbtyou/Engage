//
//  AssetFileDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/20/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class AssetFileDataSource {
    
    func fetchAsset(fromFile file: File, _ onSuccess: @escaping (_ asset: Data) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        let request = DataRequest.init(withPath: file.url)
        
        let cache = Shared.dataCache
        cache.item(forKey: request.fullPath) { (codableData) in
            if let data = codableData?.data {
                DispatchQueue.main.async {
                    onSuccess(data)
                }
                
                return
            }
            
            // - Download the data if it is not cached
            request.sendRequest { (result) in
                switch result {
                    case .error(let error):
                        onFailure(error.localizedDescription)
                    
                    case .success(let data):
                        onSuccess(data.data)
                }
            }
        }
    }
}
