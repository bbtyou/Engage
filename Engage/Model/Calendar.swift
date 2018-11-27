//
//  Calendar.swift
//  Engage
//
//  Created by Charles Imperato on 11/6/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// MARK: - Calendar event
struct CalendarEvent: Codable {
    
    let id: String
    let start: String
    let end: String
    let title: String
    let description: String
    
}
