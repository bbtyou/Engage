//
//  EngageProperties.swift
//  Engage
//
//  Created by Charles Imperato on 1/23/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

public enum EngageProperties: String {
    
    case provisioningCode
    case migrated
    
    public static func setValue(_ value: Any?, withKey key: String) {
        if let value = value {
            PropertyManager().set(value: value, forKey: key)
        }
    }
    
    public static func value(forKey key: String) -> Any? {
        return PropertyManager().property(forKey: key)
    }
    
    public var value: Any? {
        get {
            return PropertyManager().property(forKey: self.rawValue)
        }
    }
    
    public func setValue(_ value: Any?) {
        if let value = value {
            PropertyManager().set(value: value, forKey: self.rawValue)
        }
        else {
            self.remove()
        }
    }
    
    public func remove() {
        PropertyManager().remove(property: self.rawValue)
    }
}
