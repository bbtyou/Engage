//
//  ThemeDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class ThemeDataSource {
    
    let request = ThemeRequest.init()
    
    func fetchTheme(_ onSuccess: @escaping (_ theme: Theme) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode(Theme.self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
}
