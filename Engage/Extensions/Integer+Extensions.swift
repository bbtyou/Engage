//
//  Integer+Extensions.swift
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import Foundation

extension BinaryInteger {
    
    /// This computed property returns an integer as a comma separated decimal number
    var formattedWithSeparator: String {
        get {
        
            return Formatter.withCommaSeparator.string(for: self) ?? ""
        
        }
    }

}

extension Int {

    /// This computed property returns an integer as a comma separated decimal number
    var formattedWithSeparator: String {
        get {
            
            return Formatter.withCommaSeparator.string(for: self) ?? ""
            
        }
    }
    
}
