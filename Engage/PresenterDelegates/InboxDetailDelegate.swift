//
//  InboxDetailDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/22/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol InboxDetailDelegate: class {
    
    // - Notifies the view that the details for the message have loaded
    func detailsLoadComplete(_ details: InboxDetail)
    
}
