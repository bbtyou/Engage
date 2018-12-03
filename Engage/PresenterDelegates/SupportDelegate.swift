//
//  SupportDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 12/3/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol SupportDelegate: Waitable {
    
    // - Notifies the view that the support data has loaded
    func supportLoaded()
    
}
