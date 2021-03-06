//
//  ThemeDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol ThemeDelegate: class {
    // - Invoked when the theme has successfully loaded
    func themeLoaded()
    
    // - Invoked when the theme has failed to load
    func themeFailed()
}
