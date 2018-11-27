//
//  Profile.swift
//  Engage
//
//  Created by Charles Imperato on 11/6/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// MARK: - Profile

struct Profile: Codable {
    
    let name: String
    let login: String
    let street: String
    let city: String
    let state: String
    let phone: String
    
}
