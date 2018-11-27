//
//  Themable.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

protocol Stylable {}

// MARK: - UIButton

extension Stylable where Self: UIButton {
    func style() {
        guard let themer = AppConfigurator.shared.themeConfigurator else {
            log.warning("Unable to theme button because the theme configuration could not be found.")
            return
        }
        
        self.layer.cornerRadius = 5.0
        
        if let image = UIImage.imageFromColor(color: themer.themeColor) {
            self.setBackgroundImage(image, for: .normal)
        }
        
        if let image = UIImage.imageFromColor(color: UIColor.gray) {
            self.setBackgroundImage(image, for: .highlighted)
        }
    }
}

// MARK: - UITextField

extension Stylable where Self: UITextField {
    func style() {
        self.setLeftMargin(padding: 50)
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1.0
    }
}

// MARK: - UIBarButtonItem

extension Stylable where Self: UIBarButtonItem {
	func style() {
		guard let themer = AppConfigurator.shared.themeConfigurator else {
			log.warning("Unable to theme button because the theme configuration could not be found.")
			return
		}
		
		self.tintColor = themer.themeColor
	}
	
}
