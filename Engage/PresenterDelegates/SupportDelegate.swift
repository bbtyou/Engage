//
//  SupportDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 12/3/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

protocol SupportDelegate: Waitable {
    
    // - Show email
    func showEmail(_ email: String)
    
    // - Shows phone number
    func showPhone(_ phone: String)
    
    // - Shows the SMS
    func showSMS(_ sms: String)
    
    // - Hides the email
    func hideEmail()
    
    // - Hides the phone number
    func hidePhone()
    
    // - Hides SMS
    func hideSMS()
    
    // - Sets the image
    func setImage(withName name: String)
    
    // - Displays an error with a message
    func showError(_ message: String)
    
    // - Remove the error view
    func hideError()
    
    // - Compose an email
    func composeEmail(_ subject: String, _ recipients: [String], _ cc: [String], _ bcc: [String])
    
    // - Compose a text message
    func composeSMS(_ subject: String, _ recipients: [String])
    
    // - Make a phone call
    func phoneCall(_ number: String)
    
    // - Tells the view what its title should be
    func setTitle(_ title: String)
    
}
