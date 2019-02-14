//
//  ProvisioningPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class ProvisioningPresenter {
    
    // - MVP pattern delegate
    weak var delegate: ProvisioningDelegate?
    
    func migrate() {
        if let code = CommonProperties.provisioningCode.value as? String {
            if let _ = CommonProperties.migrated.value as? Bool {
                self.checkProvisioning()
                return
            }

            // - Remove the current code
            CommonProperties.provisioningCode.remove()

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
        if let _ = CommonProperties.provisioningCode.value as? String {
            self.delegate?.disableProvisioning()
            self.delegate?.provisioningSuccess(ThemePresenter())
        }
        else {
            self.delegate?.enableProvisioning()
        }
    }
    
    func provision(_ code: String, _ completion: (() -> ())? = nil) {
        if let _ = CommonProperties.provisioningCode.value as? String {
            completion?()
            return
        }
        
        if code.count == 0 {
            self.delegate?.provisioningFailed("Please enter a valid provisioning code.")
            completion?()
            return
        }

        self.delegate?.showSpinner("Provisioning account...")
        
        let dataSource = ProvisioningDataSource.init(ProvisionRequest.init(code: code))
        dataSource.provision { (provision, error) in
            self.delegate?.hideSpinner()
            
            if let error = error {
                log.error(error)
                self.delegate?.provisioningFailed("The provisioning code you entered was not recognized.  Please enter a valid provisioning code or contact your administrator for assistance.")
                completion?()
                return
            }
            
            // - Provisioning request completed
            if let prov = provision, prov.title.count > 0, prov.url.absoluteString.count > 0 {
                log.debug("Provisioning completed successfully \(prov).")

                // - Update the common properties to store the code, title and base URL
                CommonProperties.provisioningCode.setValue(code)
                CommonProperties.servicesBasePath.setValue(prov.url.absoluteString)
                CommonProperties.title.setValue(prov.title)
                
                // - Update the migration flag
                CommonProperties.migrated.setValue(true)
                
                // - Update the view
                self.delegate?.provisioningSuccess(ThemePresenter.init())
            }
            else {
                CommonProperties.provisioningCode.remove()
                log.debug("Provisioning failed.")
                self.delegate?.provisioningFailed("The account could not be provisioned using code '\(code)'.")
            }
            
            completion?()
        }
    }
    
    func completeProvision() {
        self.delegate?.navigate("login", LoginPresenter())
    }
}

