//
//  ThemeConfigurator.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import wvslib

enum ThemeLogo: Int {
    case small
    case medium
    case large
}

class ThemeConfigurator {
    
    private var theme = Theme.init(largeLogoUrl: "", mediumLogoUrl: "", smallLogoUrl: "", themeColor: "5C4390", gradientStart: "", gradientEnd: "", appMenuTextColor: "515351")
    
    // - Theme colors
    var themeColor: UIColor {
        get {
            return UIColor.colorWithHexValue(hex: self.theme.themeColor, alpha: 1.0)
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
    
    init(withTheme theme: Theme) {
        self.theme = theme
    }

    func logo(_ size: ThemeLogo = .small, _ completion: @escaping (_ image: UIImage?) -> ()) {
        var logoUrl: String = ""
        
        switch size {
            case .small:
                logoUrl = theme.smallLogoUrl
            
            case .medium:
                logoUrl = theme.mediumLogoUrl
            
            case .large:
                logoUrl = theme.largeLogoUrl
        }
        
        let imageRequest = ImageRequest.init(path: logoUrl)
        
        imageRequest.sendRequest { (response, data, error) in
            if let e = error {
                log.error(e)
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage.init(data: data) {
                completion(image)
                return
            }

            log.warning("The image data retrieved was invalid.")
            completion(nil)
        }
    }
    
    
}
