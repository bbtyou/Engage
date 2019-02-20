//
//  ThemePresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class ThemePresenter {
    // - View delegate
    weak var delegate: ThemeDelegate?
    
    func loadTheme() {
        (self.delegate as? Waitable)?.showSpinner("Updating application theme...")
        
        LocalCurrent.theming().theme { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let theme):
                Properties<String>.themeColor.setValue(value: theme.themeColor)
                Properties<String>.logoUrl.setValue(value: theme.smallLogoUrl)
                self.delegate?.themeLoaded()
                
            case .failure(let error):
                Current.log().error(error)
                self.delegate?.themeFailed()
            }
        }
    }
}
