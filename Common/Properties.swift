//
//  Properties.swift
//  Engage
//
//  Created by Charles Imperato on 2/18/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

enum Properties<T: Codable>: String {
    case basepath
    case title
    case provisioningCode
    case themeColor
    case logoUrl
    
    var value: T? {
        get {
            let pm = PropertyManager(withUserId: nil)
            return pm.property(forKey: self.rawValue) as? T
        }
    }
    
    func setValue(value: T) {
        PropertyManager(withUserId: nil).set(value: value, forKey: self.rawValue)
    }
}
