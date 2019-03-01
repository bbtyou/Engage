//
//  UIImage+Extensions.swift
//  Engage
//
//  Created by Charles Imperato on 2/28/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func drawBadge() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        
        self.draw(at: .zero)
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()
        
        // - Set the stroking color to red
        UIColor.red.setStroke()

        let circle = CGRect.init(x: self.size.width - 6.0, y: 0, width: 12.0, height: 12.0)
        context?.strokeEllipse(in: circle)
        context?.setFillColor(UIColor.red.cgColor)
        context?.fillEllipse(in: circle)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
