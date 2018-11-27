//
//  Formatter+Extensions.swift
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import Foundation

extension Formatter {
    
    static let withCommaSeparator: NumberFormatter = {

        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal

        return formatter
        
    }()
}
