//
//  ThemePresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class ThemePresenter {
    
    weak var delegate: ThemeDelegate?
    
    func loadTheme() {
        let ds = ThemeDataSource.init()
        
        self.delegate?.showSpinner("Updating theme...")
        ds.fetchTheme { (theme, error) in
            self.delegate?.hideSpinner()
            
            if let e = error {
                log.error(e)
                self.delegate?.themeFailed()
                return
            }
            
            if let theme = theme {
                AppConfigurator.shared.updateTheme(withTheme: theme)
                self.delegate?.themeLoaded()
                return
            }
            
            self.delegate?.themeFailed()
        }
    }
    
}
