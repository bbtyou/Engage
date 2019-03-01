//
//  Cache+Extensions.swift
//  wvslib
//
//  Created by Charles Imperato on 2/23/19.
//  Copyright © 2019 Wind Valley Software. All rights reserved.
//

import Foundation
import UIKit

public extension Cache where T == CodableImage {
    // - This method attmpts to retrieve an image from the cache first.  If the image is not found
    // - an image request will be made to retrieve the image from the server.
    func fetchImage(_ base: String, _ path: String, _ size: CGSize? = nil, _ tint: UIColor? = nil, _ completion: @escaping (_ image: UIImage?, _ url: URL?) -> ()) {
        let url = URL.init(string: "\(base)/\(path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")")

        self.item(forKey: "\(base)/\(path)") { (codable) in
            guard let image = codable?.image else {
                ImageRequest(base: base, path: path).send({ (result) in
                    switch result {
                    case .success(let image):
                        self.set(CodableImage(image: image.0), forKey: "\(base)/\(path)")
                        completion(self.updateImage(image.0, size, tint), url)
                        
                    case .failure(let error):
                        DispatchQueue.main.async { print("Fetching the image failed: \(error).") }
                        completion(nil, url)
                    }
                })
                
                return
            }
            
            completion(self.updateImage(image, size, tint), url)
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
