//
//  Stylable.swift
//  Engage
//
//  Created by Charles Imperato on 2/18/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

protocol Stylable {}

// MARK: - UIButton
extension UIButton: Stylable {}

extension Stylable where Self: UIButton {
    func style() {
        self.layer.cornerRadius = 5.0
        
        if let theme: String = Properties.themeColor.value, let color = UIColor.colorWithAlphaHexValue(theme), let image = UIImage.imageFromColor(color: color) {
            self.setBackgroundImage(image, for: .normal)
        }
        
        if let image = UIImage.imageFromColor(color: UIColor.gray) {
            self.setBackgroundImage(image, for: .highlighted)
        }
    }
}

// MARK: - UITextField
extension UITextField: Stylable {}

extension Stylable where Self: UITextField {
    func style() {
        self.setLeftMargin(padding: 50)
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1.0
    }
}

// MARK: - UIBarButtonItem
extension UIBarButtonItem: Stylable {}

extension Stylable where Self: UIBarButtonItem {
    func style() {
        if let theme: String = Properties.themeColor.value, let color = UIColor.colorWithAlphaHexValue(theme) {
            self.tintColor = color
        }
    }
}
