//
//  UIImage+Extensions
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    enum PhotoQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1.0
    }
    
    // - This method takes an image from the asset catalog and masks it with the
    // - color specified as the tint color
    class func maskedImage(name: String, tintColor: UIColor, bundle: Bundle? = nil) -> UIImage? {
        guard let image = UIImage.init(named: name, in: bundle, compatibleWith: nil) else {
            return nil
        }
        
        return image.maskedImage(with: tintColor)
    }
    
    // - This method converts the image into a new image with the specified tint color
    func maskedImage(with tintColor: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        guard let cgi = self.cgImage, let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        
        var image: UIImage = self
        
        // - Draw the image in the context
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let translateHeight = floor(rect.size.height)
        
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.translateBy(x: 0.0, y: -translateHeight)
        
        ctx.clip(to: rect, mask: cgi)
        ctx.setFillColor(tintColor.cgColor)
        ctx.fill(rect)
        
        ctx.translateBy(x: 0.0, y: translateHeight)
        ctx.scaleBy(x: 1.0, y: -1.0)
        
        // - Get the image
        if let contextImage = UIGraphicsGetImageFromCurrentImageContext() {
            image = contextImage
        }
        
        // - Clean up
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    // This method returns an image based on a color
    class func imageFromColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// Rotates an image clockwise by the number of degrees specified.
    /// This method returns a newly created image with the specified
    /// rotation applied to the original.
    func imageRotatedByDegrees(deg degrees: CGFloat) -> UIImage {
        
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        
        //Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// This method resizes the image based on a height and scales
    /// it down to preserve aspect and rendering quality
    func resize(toHeight height: CGFloat) -> UIImage? {
        var newImage: UIImage?
        
        /// Take the max between height and width and use as the scale
        let scale = height / self.size.height
        let width = self.size.width * scale
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        /// Get the new image and return it
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// This method resizes the image based on a width and scales it down to
    /// to preserve aspect and rendering quality
    func resize(toWidth width: CGFloat) -> UIImage? {
        var newImage: UIImage?
        
        /// Take the max between height and width and use as the scale
        let scale = width / self.size.width
        let height = self.size.height * scale
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        /// Get the new image and return it
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// This method produces a JPEG representation of a UIImage with set image quality
    func jpegImage(quality: PhotoQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    /// This method returns the image with the alpha setting
    func image(_ alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func ==(_ lhs: UIImage, _ rhs: UIImage) -> Bool {
        if let dataLeft = lhs.pngData(), let dataRight = rhs.pngData() {
            return dataLeft == dataRight
        }
        
        return false
    }
    
    var hasAlpha: Bool {
        guard let alpha = self.cgImage?.alphaInfo else {
            return false
        }
        
        switch alpha {
        case .none, .noneSkipLast, .noneSkipFirst:
            return false
            
        default:
            return true
        }
    }
    
    var data: Data? {
        return self.hasAlpha ? self.pngData() : self.jpegData(compressionQuality: 1.0)
    }
    
    func base64EncodedPNGImage() -> String? {
        if let imgData = self.pngData() {
            return imgData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        }
        
        return nil
    }
}
