//
//  CalendarDetailDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/24/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// Event detail type for the view
typealias CalendarEventDetail = (time: String, date: String, topic: String, body: String)

protocol CalendarDetailDelegate: class {
    
    // - Notifies the view that the detail info has been loaded
    func detailLoaded(_ detail: CalendarEventDetail)
    
}
