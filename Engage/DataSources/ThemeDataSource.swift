//
//  ThemeDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class ThemeDataSource: RestResponseCheckable {
    
    let request = ThemeRequest.init()
    
    func fetchTheme(_ completion: @escaping (_ theme: Theme?, _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion(nil, err)
                return
            }
            
            do {
                
                // - Get the theme data
                guard let data = data else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }

                let theme = try JSONDecoder().decode(Theme.self, from: data)
                completion(theme, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion(nil, jsonError)
            }
        }
    }
}
