//
//  Themeable.swift
//  Engage
//
//  Created by Charles Imperato on 2/18/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

// Themeable protocol for themeable UI components in the app
protocol Themeable {}

extension Themeable {
    // - Theme colors
    var themeColor: UIColor {
        get {
            guard let theme: String = Properties.themeColor.value else { return UIColor.darkGray }
            return UIColor.colorWithHexValue(hex: theme, alpha: 1.0)
        }
    }
    
    var bodyTextColor: UIColor {
        get {
            return UIColor.colorWithHexValue(hex: "8e8e8e", alpha: 1.0)
        }
    }
    
    var headerTextColor: UIColor {
        get {
            return UIColor.colorWithHexValue(hex: "515251", alpha: 1.0)
        }
    }
    
    var backgroundColor: UIColor {
        get {
            return UIColor.colorWithHexValue(hex: "e8e8e8", alpha: 1.0)
        }
    }
    
    func logo(_ completion: @escaping (_ image: UIImage?) -> ()) {
        Current.image().logo { result in
            switch result {
            case .success(let image):
                completion(image.0)
                
            case .failure(let error):
                Current.log().error(error)
                completion(nil)
            }
        }
    }
}
