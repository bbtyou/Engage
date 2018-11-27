//
//  UIColor+Extensions
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func colorWithAlphaHexValue(_ hex: String) -> UIColor? {
        guard hex.length == 6 || hex.length == 8 else {
            return nil
        }
        
        let normalizedHex = UIColor.normalizeHexString(hex)
        let scanner = Scanner(string: normalizedHex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        if scanner.scanHexInt64(&rgbValue) == false {
            return nil
        }
        
        var r: UInt64 = 0
        var g: UInt64 = 0
        var b: UInt64 = 0
        var a: UInt64 = 0
        
        if hex.length == 8 {
            r = (rgbValue & 0xff000000) >> 24
            g = (rgbValue & 0x00ff0000) >> 16
            b = (rgbValue & 0x0000ff00) >> 8
            a = rgbValue & 0x000000ff
        } else {
            r = (rgbValue & 0xff0000) >> 16
            g = (rgbValue & 0x00ff00) >> 8
            b = rgbValue & 0x0000ff
            a = 255
        }
        
        return UIColor.init(red: (CGFloat(r) / 255.0), green: (CGFloat(g) / 255.0), blue: (CGFloat(b) / 255.0), alpha: (CGFloat(a) / 255.0))
        
    }
    
    // - This method returns a UIColor object based on a hex string that represents the color.  An alpha can be specified as well.
    static func colorWithHexValue(hex: String, alpha: Float) -> UIColor {
        let scanner = Scanner(string: UIColor.normalizeHexString(hex))
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0x00ff00) >> 8
        let b = rgbValue & 0x0000ff
        
        return UIColor(red: (CGFloat(r) / 255.0), green: (CGFloat(g) / 255.0), blue: (CGFloat(b) / 255.0), alpha: CGFloat(alpha))
    }

    // - This method will return a string hex value for a color
    func hexValue() -> String {
        let components = self.cgColor.components
        let red = components?[0]
        let green = components?[1]
        let blue = components?[2]
        
        if let r = red, let g = green, let b = blue {
            return String.init(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
        
        return ""
    }
    
    fileprivate static func normalizeHexString(_ hex: String) -> String {
       return hex.replacingOccurrences(of: "#", with: "")
    }
}
