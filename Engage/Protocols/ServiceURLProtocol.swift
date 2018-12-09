//
//  ServiceURLProtocol.swift
//  Engage
//
//  Created by Charles Imperato on 12/8/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class ServiceURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        if let url = request.url {
            print("Request URL = \(url.absoluteString)")
        }
        
        return false
    }
    
    
}
