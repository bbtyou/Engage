//
//  OrientationConfigurable.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

// - Determines if the device is a phone other than plus size and sets
// - the supported orientation to portrait only.  All other devices support
// - Landscape.
protocol OrientationConfigurable {
    
    // - Supported interface orientations based on device.  Plus size and tablets
    // - will support all orientations while phones support portrait only
    var portraitForPhone: UIInterfaceOrientationMask { get }
    
}

extension OrientationConfigurable where Self: UIViewController {
    
    var portraitForPhone: UIInterfaceOrientationMask {
        if UIDevice.current.isPlusModelPhone {
            return .all
        }
        
        if UIDevice.current.sizeClass == .compact {
            return .portrait
        }
        
        return .all
    }
}
