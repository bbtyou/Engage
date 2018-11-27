//
//  UITextField+Extensions
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import Foundation
import UIKit

extension UITextField: Stylable {}

extension UITextField {
    
    // - This method allows the setting of the left margin inset for a text field
    func setLeftMargin(padding: CGFloat) {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        self.leftView?.backgroundColor = UIColor.clear
        self.leftViewMode = .always
    }

    // - This method allows the setting of the right margin inset for a text field
    func setRightMargin(padding: CGFloat) {
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        self.rightView?.backgroundColor = UIColor.clear
        self.rightViewMode = .always
    }

}
