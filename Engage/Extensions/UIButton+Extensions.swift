//
//  UIButton+Extensions.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

// MARK: - Stylable button

extension UIButton: Stylable {}

extension UIButton {
    
    // - This method allows for easy setting of a font for a button state
    public func set(font: UIFont, color: UIColor?, forState state: UIControl.State) {
        guard let title = self.title(for: state) else {
            return
        }
        
        if let color = color {
            let attributedText = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
            self.setAttributedTitle(attributedText, for: state)
        }
        else {
            let attributedText = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: font])
            self.setAttributedTitle(attributedText, for: state)
        }
    }
    
    public func set(imageMargin: CGFloat, andTitleMargin titleMargin: CGFloat, forWidth width: CGFloat) {
        
        var contentMargin: CGFloat = 0.0
        var separation: CGFloat = 0.0
        
        //have to do these together as margin from left if determines by finding out total size of content
        if imageMargin > 0, let imageWidth = self.image(for: .normal)?.size.width,
            let titleSize = self.attributedTitle(for: .normal)?.boundingRect(with: CGSize.init(width: 1000.0, height: 50.0), options: .usesLineFragmentOrigin, context: nil) {
            
            separation = titleMargin - imageMargin - imageWidth
            let contentWidth = ceil(titleSize.width + imageWidth + separation)
            
            let remainingSpace = width - contentWidth
            
            contentMargin = (remainingSpace / 2.0) - imageMargin
        }
        
        let inset = separation / 2.0
        
        self.imageEdgeInsets = UIEdgeInsets.init(top: 0.0, left: -inset, bottom: 0.0, right: inset)
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: inset, bottom: 0.0, right: -inset)
        self.contentEdgeInsets = UIEdgeInsets.init(top: 0.0, left: (inset - contentMargin), bottom: 0.0, right: (inset + contentMargin))
        
    }
    
    /// This method sets the image to be directly in the
    /// center of the button.  If the button has text, the
    /// text will be removed.
    public func setCenterImage(image: UIImage, for state: UIControl.State) {
        
        self.setTitle(nil, for: state)
        self.contentMode = .center
        
        // Get the maximum between height and width
        let dimensionSize = max(image.size.width, image.size.height)
        if dimensionSize == image.size.width {
            
            let newWidth = min(self.bounds.width - 20, dimensionSize)
            self.setImage(image.resize(toWidth: newWidth), for: state)
            
        }
        else {
            
            let newHeight = min(self.bounds.height - 20, dimensionSize)
            self.setImage(image.resize(toHeight: newHeight), for: state)
            
        }
        
    }
    
    //This method will change the insets of the button such that the image will appear above the
    //title with a separation between them specified by the padding.
    //This method must be called after the button has been initially layed out as it needs to know the title and image sizes
    public func centerVertically(withPadding padding: CGFloat) {
        
        guard let imageSize = self.imageView?.frame.size, let titleSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = ceil(imageSize.height) + ceil(titleSize.height) + padding
        
        self.imageEdgeInsets = UIEdgeInsets.init(top: -(totalHeight - ceil(imageSize.height)), left: 0.0, bottom: 0.0, right: -ceil(titleSize.width))
        
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: -ceil(imageSize.width), bottom: -(totalHeight - ceil(titleSize.height)), right: 0.0)
        
        self.contentEdgeInsets = UIEdgeInsets.init(top: ceil(titleSize.height) + padding, left: 0.0, bottom: ceil(titleSize.height), right: 0.0)
        
    }
    
    public func addSpacingBetweenImageAndText(_ spacing: CGFloat) {
        
        let inset = spacing / 2.0
        
        self.imageEdgeInsets = UIEdgeInsets.init(top: 0.0, left: -inset, bottom: 0.0, right: inset)
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: inset, bottom: 0.0, right: -inset)
        self.contentEdgeInsets = UIEdgeInsets.init(top: 0.0, left: inset, bottom: 0.0, right: inset)
        
    }
    
    public func setBackgroundColor(_ color: UIColor, forState state:UIControl.State) {
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = color
        
        var colorImage: UIImage?
        UIGraphicsBeginImageContext(backgroundView.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            backgroundView.layer.render(in: context)
        }
        
        colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: state)
    }}
