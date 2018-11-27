//
//  PropertyManager.swift
//  Engage
//
//  Created by Charles Imperato on 11/6/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class PropertyManager {
    
    static let shared = PropertyManager()
    
    private init() {

    }
    
    func property(forKey key: String) -> Any? {
        return UserDefaults.standard.value(forKey: self.propKey(forKey: key))
    }

    func set(value: Any, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func remove(property key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Private
    
    private func propKey(forKey key: String) -> String {
        // Any key containing "%@" is a user specific key
        var propKey = key
        if let _ = propKey.range(of: "%@"), let userId = AppConfigurator.shared.userInfo?.userId {
            propKey = String.init(format: key, userId)
        }
        
        return propKey
    }
}
