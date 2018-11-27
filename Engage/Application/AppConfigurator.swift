//
//  AppConfigurator.swift
//  Engage
//
//  Created by Charles Imperato on 11/6/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//
import Foundation

// Global logger
let log = Log()

class AppConfigurator {
    
    static let shared = AppConfigurator()
    
    // - Set the user info
    var userInfo: UserData?
    
    // - Returns theme configuration data
    var themeConfigurator: ThemeConfigurator? {
        get {
            if let theme = self.theme {
                return ThemeConfigurator.init(withTheme: theme)
            }
            
            return nil
        }
    }

    // - Returns the action handler
    var actionHandler: ActionHandler {
        get {
            return AppActionHandler.init()
        }
    }
    
    // - Theme
    private var theme: Theme?
    
    // - Private intiializer for singleton
    private init() {}

    // - Update the theme if it changes
    func updateTheme(withTheme theme: Theme) {
        self.theme = theme
    }
}

