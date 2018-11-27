//
//  UIImageView+Extensions.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

extension UIImageView: Waitable {
    
    func fetchImage(_ path: String, _ useSpinner: Bool = false, _ placeholder: UIImage? = nil, _ size: CGSize? = nil, _ tint: UIColor? = nil) {
        // - If the path is empty we use the placeholder by default
        if path.trimmingCharacters(in: .whitespaces).count == 0 {
            log.debug("Image path is empty, attempting to use placeholder image.")

            self.image = placeholder
            self.updateImage(size, tint)
            return
        }

        // - Attempt to use the name to get a local image
        if path.trimmingCharacters(in: .whitespaces).contains("/") == false {
            log.debug("Image path not specified as a path, attempting to use local name.")
            
            self.image = UIImage.init(named: path)
            self.updateImage(size, tint)
            return
        }
        
        if useSpinner {
            self.showSpinner(nil)
        }
        
        self.image = placeholder
        
        let cache = Shared.imagesCache
        cache.fetchImage(path, size, tint) { (image) in
            DispatchQueue.main.async {
                self.hideSpinner()
                
                guard let image = image else {
                    self.image = placeholder
                    self.updateImage(size, tint)
                    return
                }
                
                self.image = image
            }
        }
    }
        
    private func updateImage(_ size: CGSize?, _ tint: UIColor?) {
        // - Resize the image
        guard let image = self.image else {
            return
        }
        
        if let size = size, let resizedImage = image.resize(toWidth: size.width)?.resize(toHeight: size.height) {
            self.image = resizedImage
        }
        
        // - Change the tint color if specified
        if let tint = tint, let tintedImage = self.image?.maskedImage(with: tint) {
            self.image = tintedImage
        }

    }
}
