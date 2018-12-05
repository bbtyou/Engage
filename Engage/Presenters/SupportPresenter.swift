//
//  SupportPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 12/3/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

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
        
        self.delegate?.showSpinner("Loading contact info...")
        
        let dataSource = PortalDataSource.init()
        dataSource.fetchSupportContact { (contact, error) in
            self.delegate?.hideSpinner()
            
            if let error = error {
                log.error("The support contact info could not be retrieved. \(error.localizedDescription).")
                self.delegate?.showError("Support contact information was not able to be retrieved.  \(error.localizedDescription).")
                return
            }
            
            guard let contact = contact else {
                log.warning("No contact info was found.")
                self.delegate?.showError("No contact info was found.")
                return
            }
            
            self.delegate?.hideError()
            
            // - Tell the view which image to load
            var imageName = "support_large"
            if self.type == .tech {
                imageName = "techsupport_large"
                if contact.techSupport.count == 0 {
                    self.delegate?.showError("Oops!  There is no support contact information available at this time.")
                    return
                }
            }
            else if self.type == .rep {
                if contact.repEmail.count == 0, contact.repPhone.count == 0, contact.repSMS.count == 0 {
                    self.delegate?.showError("Oops!  There is no support contact information available at this time.")
                    return
                }
            }
            
            // - Set the image
            self.delegate?.setImage(withName: imageName)

            if self.type == .rep {
                contact.repEmail.count == 0 ? self.delegate?.hideEmail() : self.delegate?.showEmail(contact.repEmail)
                contact.repPhone.count == 0 ? self.delegate?.hidePhone() : self.delegate?.showPhone(contact.repPhone)
                contact.repSMS.count == 0 ? self.delegate?.hideSMS() : self.delegate?.showSMS(contact.repSMS)
            }
            else if self.type == .tech {
                contact.techSupport.count == 0 ? self.delegate?.hideEmail() : self.delegate?.showEmail(contact.techSupport)
                
                // - Tech support only has email
                self.delegate?.hideSMS()
                self.delegate?.hidePhone()
            }
            
            self.contact = contact
        }
    }
    
    func sendEmail() {
        guard let contact = self.contact else {
            log.warning("The email could not be sent because there is no contact information available.")
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
            log.warning("The message could not be sent because there is no contact information available.")
            return
        }
        
        if self.type == .rep {
            self.delegate?.composeSMS("Rep Questions", [contact.repSMS])
        }
    }
    
    func phoneCall() {
        guard let contact = self.contact else {
            log.warning("The phone call could not be made because there is no contact information available.")
            return
        }
        
        if self.type == .rep {
            self.delegate?.phoneCall(contact.repPhone)
        }
    }
}
