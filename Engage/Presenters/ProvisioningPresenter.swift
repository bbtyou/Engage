//
//  ProvisioningPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class ProvisioningPresenter {
    
    // - MVP pattern delegate
    weak var delegate: ProvisioningDelegate?

    func migrate() {
        if let code = EngageProperties.provisioningCode.value as? String {
            if let _ = EngageProperties.migrated.value as? Bool {
                self.checkProvisioning()
                return
            }
            
            // - Remove the existing code
            EngageProperties.provisioningCode.remove()

            // - We have a code from a previous version
            self.delegate?.disableProvisioning()
            self.delegate?.showSpinner("Migrating your account...")
            self.provision(code)
        }
        else {
            self.checkProvisioning()
        }
    }
    
    func checkProvisioning() {
        if let _ = EngageProperties.provisioningCode.value as? String {
            self.delegate?.disableProvisioning()
            self.delegate?.provisioningSuccess(ThemePresenter())
        }
        else {
            self.delegate?.enableProvisioning()
        }
    }
    
    func provision(_ code: String, _ completion: (() -> ())? = nil) {
        if let _ = EngageProperties.provisioningCode.value as? String {
            completion?()
            return
        }
        
        if code.count == 0 {
            self.delegate?.provisioningFailed("Please enter a valid provisioning code.")
            completion?()
            return
        }

        self.delegate?.showSpinner("Provisioning account...")
        
        let dataSource = ProvisioningDataSource.init()
        dataSource.provision({ (provision) in
            self.delegate?.hideSpinner()
            
            // - Provisioning request completed
            if provision.title.count > 0, provision.url.absoluteString.count > 0 {
                log.debug("Provisioning completed successfully. \(provision).")
                
                // - Update the common properties to store the code, title and base URL
                EngageProperties.provisioningCode.setValue(code)
                CommonProperties.servicesBasePath.setValue(provision.url.absoluteString)
                CommonProperties.title.setValue(provision.title)
                
                // - Update the migration flag
                EngageProperties.migrated.setValue(true)
                
                // - Update the view
                self.delegate?.provisioningSuccess(ThemePresenter.init())
                completion?()
            }
        }) { (error) in
            self.delegate?.hideSpinner()
            
            EngageProperties.provisioningCode.remove()
            log.error("Provisioning failed: \(error)")
            
            self.delegate?.provisioningFailed("The account could not be provisioned using code '\(code)'. \(error)")
            completion?()
        }
    }
    
    func completeProvision() {
        self.delegate?.navigate("login", LoginPresenter())
    }
}

