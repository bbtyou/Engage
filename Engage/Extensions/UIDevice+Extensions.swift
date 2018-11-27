//
//  UIDevice+Extensions
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//


import Foundation
import UIKit
import LocalAuthentication

extension UIDevice {
    
    /// Returns true if we are running on the simulator
    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    var hasTouchId: Bool {
        get {
            let context = LAContext()
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        }
    }
    
    /// Returns true if this is a "plus" module iPhone. false otherwise
    var isPlusModelPhone: Bool {
        get {
            /***
             * The problem we have is we want to know if this "plus" model iPhone so we know whether or not to allow
             * landscape. Although Apple provides size class in the trait collection, the problem is that the size class
             * won't indicate this is a "plus" phone until *after* we have already rotated into landscape. This leads to
             * a bit of a chicken and egg problem in that we only want to allow landscape on "plus" phones but we
             * don't know it is a "plus" phone until after the rotation has occured.
             *
             * The less than ideal solution is to look at the screen size to determine this.  I would call this a
             * "brittle" solution but unfortunately it seems to be the best we have as Apple does not give us any
             * other alternative.
             ***/
            
            return self.userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.width > 1200 && UIScreen.main.nativeBounds.height > 2000
        }
    }
    
    var sizeClass: UIUserInterfaceSizeClass {
        get {
            
            if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
                if viewController.view.bounds.size.width > viewController.view.bounds.size.height {
                    return viewController.traitCollection.verticalSizeClass
                } else {
                    return viewController.traitCollection.horizontalSizeClass
                }
            }
            
            return .compact
            
        }
    }
    
    var isInLandscape: Bool {
        get {
            //We will base portait/landscape based on relationship between width and height instead of status bar orientation
            //The reason is for iPad multitasking.  The _device_ may be landscape but the app may need to be treated as being in
            //portrait for display purposes
            if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
                return viewController.view.bounds.size.width > viewController.view.bounds.size.height
            }
            
            return false
        }
    }
    
}
