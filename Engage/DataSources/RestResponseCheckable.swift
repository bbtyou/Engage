//
//  RestResponseCheckable.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol RestResponseCheckable {}

extension RestResponseCheckable {
    func checkResponse(_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Error? {
        var respError: Error?
        
        if let resp = response {
            log.debug("HTTP response = \(resp)")
        }
        
        if let e = error {
            log.error(e)
            respError = e
        }
        else if let code = response?.statusCode, code != 200 {
            respError = RestClientError.error(forCode: code)
        }
        else if data == nil {
            respError = RestClientError.unknown
        }
        
        return respError
    }
}
