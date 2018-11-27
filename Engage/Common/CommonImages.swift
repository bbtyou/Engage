//
//  CommonImages.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

enum CommonImages: String {
  
    case logo = "engagelogo"
    case back = "back_button"
    case refresh = "refresh_icon"
    case provisioning = "provisioning_icon"
    case username = "username_icon"
    case password = "password_icon"
    case loadspinner = "Loading"
    case webpage = "webpage"
    case errorsignal = "errorsignal"
    case infosignal = "infosignal"
    case home = "home"
    case calendar = "calendar"
    case inbox = "inbox"
    case emptyimage = "empty_image"
    case logout = "logout"
    case longpress = "longpress"
    case favoritesenabled = "favorites_enabled"
    case favoritesdisabled = "favorites_disabled"
    case dailyupdatebg = "dailyupdate_bg"
    
    var image: UIImage? {
        get {
            return UIImage.init(named: self.rawValue)
        }
    }
    
    var imageSequence: [UIImage]? {
        get {
            var sequence = [UIImage]()
            
            var index = 1
            while (true) {
                let imageName = self.rawValue + "-\(index)"
                
                if let image = UIImage.init(named: imageName) {
                    sequence.append(image)
                }
                else {
                    break
                }
                
                index += 1
            }
            
            if sequence.count == 0 {
                return nil
            }
            
            return sequence
        }
    }
}
