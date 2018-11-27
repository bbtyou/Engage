//
//  TypeWrapper.swift
//  Engage
//
//  Created by Charles Imperato on 11/18/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CodableImage

struct CodableImage: Codable {
    
    let image: UIImage
    
    enum CodingKeys: String, CodingKey {
        case image
    }
    
    init(image: UIImage) {
        self.image = image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        guard let image = UIImage.init(data: data) else {
            self.image = UIImage.init()
            return
        }
        
        self.image = image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let data = self.image.data else {
            return
        }
        
        try container.encode(data, forKey: CodingKeys.image)
    }
}

// MARK: - CodableData

struct CodableData: Codable {
    let data: Data
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(data: Data) {
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode(Data.self, forKey: CodingKeys.data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.data, forKey: CodingKeys.data)
    }
}
