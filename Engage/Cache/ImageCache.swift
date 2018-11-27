//
//  ImageCache.swift
//  Engage//
//  Created by Charles Imperato on 11/18/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

extension Cache where T == CodableImage {
    
    // - This method attmpts to retrieve an image from the cache first.  If the image is not found
    // - an image request will be made to retrieve the image from the server.
    func fetchImage(_ path: String, _ size: CGSize? = nil, _ tint: UIColor? = nil, _ result: @escaping (_ image: UIImage?) -> ()) {
        let request = ImageRequest.init(path: path)

        self.item(forKey: request.fullPath) { (codableImage) in
            if let image = codableImage?.image {
                result(self.updateImage(image, size, tint))
                return
            }
            
            // - If the image could not be found in the cache then attempt to retrieve it remotely
            request.sendRequest({ (response, data, error) in
                if let error = error {
                    log.error("Image with path = \(request.fullPath) could not be retrieved. \(error)")
                    result(nil)
                    return
                }
                
                if let data = data, let image = UIImage.init(data: data) {
                    result(self.updateImage(image, size, tint))
                    return
                }
                
                log.warning("Image with path = \(request.fullPath) could not be retrieved.")
                result(nil)
            })
        }
    }
    
    // MARK: - Private
    
    private func updateImage(_ image: UIImage, _ size: CGSize?, _ tint: UIColor?) -> UIImage {
        var updatedImage = image
        
        if let size = size, let resizedImage = updatedImage.resize(toWidth: size.width)?.resize(toHeight: size.height) {
            updatedImage = resizedImage
        }
        
        // - Change the tint color if specified
        if let tint = tint {
            updatedImage = updatedImage.maskedImage(with: tint)
        }
        
        return updatedImage
    }
}
