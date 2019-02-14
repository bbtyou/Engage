//
//  ProvisioningDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class ProvisioningDataSource: RestResponseCheckable {
    
    let request: ProvisionRequest
    
    init(_ request: ProvisionRequest) {
        self.request = request
    }
    
    func provision(_ completion: @escaping (_ provisioning: Provision?, _ error: Error?) -> ()) {
        self.request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion(nil, err)
                return
            }
            
            do {
                
                // - Get the provisioning json from the data
                guard let data = data else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Serialize the json back to Data and decode to provision object
                let provision = try JSONDecoder().decode(Provision.self, from: data)
                completion(provision, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion(nil, jsonError)
            }

        }
    }
}
