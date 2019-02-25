//
//  SupportPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 12/3/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

enum SupportType: Int {
    case rep
    case tech
    case doc
}

class SupportPresenter {
    
    // - Type of support
    fileprivate var type: SupportType = .rep
    
    // - Contact data for the support type
    fileprivate var contact: Contact?
    
    init(withType type: SupportType) {
        self.type = type
    }
    
    // - View delegate
    weak var delegate: SupportDelegate?
    
    func load() {
        switch self.type {
        case .rep:
            self.delegate?.setTitle("Rep Questions")
        
        case .tech:
            self.delegate?.setTitle("Tech Support")
        
        default:
            self.delegate?.setTitle("Support")
        }
        
        (self.delegate as? Waitable)?.showSpinner("Loading contact info...")
        
        Current.main().portal(false) { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let portal):
                self.delegate?.hideError()

                var imageName = "support_large"
                if self.type == .tech {
                    imageName = "techsupport_large"
                    if portal.contact.techSupport.count == 0 {
                        self.delegate?.showError("Oops! There is no support contact information available at this time.")
                    }
                }
                else if self.type == .rep {
                    if portal.contact.repEmail.count == 0, portal.contact.repPhone.count == 0, portal.contact.repSMS.count == 0 {
                        self.delegate?.showError("Oops! There is no support contact information available at this time.")
                        return
                    }
                }
                
                // - Set the image
                self.delegate?.setImage(withName: imageName)
                
                if self.type == .rep {
                    portal.contact.repEmail.count == 0 ? self.delegate?.hideEmail() : self.delegate?.showEmail(portal.contact.repEmail)
                    portal.contact.repPhone.count == 0 ? self.delegate?.hidePhone() : self.delegate?.showPhone(portal.contact.repPhone)
                    portal.contact.repSMS.count == 0 ? self.delegate?.hideSMS() : self.delegate?.showSMS(portal.contact.repSMS)
                }
                else if self.type == .tech {
                    portal.contact.techSupport.count == 0 ? self.delegate?.hideEmail() : self.delegate?.showEmail(portal.contact.techSupport)
                    
                    // - Tech support only has email
                    self.delegate?.hideSMS()
                    self.delegate?.hidePhone()
                }
                
                self.contact = portal.contact
                
            case .failure(let error):
                self.delegate?.showError(error.localizedDescription)
            }
        }
    }
    
    func sendEmail() {
        guard let contact = self.contact else {
            Current.log().warning("The email could not be sent because there is no contact information available.")
            return
        }
        
        if self.type == .rep {
            self.delegate?.composeEmail("Rep Questions", [contact.repEmail], [], [])
        }
        else if self.type == .tech {
            self.delegate?.composeEmail("Tech Support", [contact.techSupport], [], [])
        }
    }
    
    func sendText() {
        guard let contact = self.contact else {
            Current.log().warning("The message could not be sent because there is no contact information available.")
            return
        }
        
        if self.type == .rep {
            self.delegate?.composeSMS("Rep Questions", [contact.repSMS])
        }
    }
    
    func phoneCall() {
        guard let contact = self.contact else {
            Current.log().warning("The phone call could not be made because there is no contact information available.")
            return
        }
        
        if self.type == .rep {
            self.delegate?.phoneCall(contact.repPhone.filter("0123456789.".contains))
        }
    }
}
