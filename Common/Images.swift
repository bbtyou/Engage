//
//  Images.swift
//  Engage
//
//  Created by Charles Imperato on 2/20/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

enum Images: String {
    case calendar
    case home
    case inbox
    case webpage
    case logo
    case favoritesdisabled
    case favoritesenabled
    case longpress
    
    var image: UIImage? {
        get {
            return UIImage.init(named: self.rawValue)
        }
    }
}
