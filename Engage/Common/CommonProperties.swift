//
//  CommonProperties.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

enum CommonProperties: String {
    
    case provisioningBasePath
    case servicesBasePath
    case provisioningCode
    case title
    case userid
    case migrated
    
    var value: Any? {
        get {
            return PropertyManager.shared.property(forKey: self.rawValue)
        }
    }
    
    func setValue(_ value: Any?) {
        if let value = value {
            PropertyManager.shared.set(value: value, forKey: self.rawValue)
        }
        else {
            self.remove()
        }
    }
    
    func remove() {
        PropertyManager.shared.remove(property: self.rawValue)
    }
}
