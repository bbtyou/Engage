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
    
    func checkProvisioning() {
        if let _ = CommonProperties.provisioningCode.value as? String {
            self.delegate?.disableProvisioning()
            self.delegate?.provisioningSuccess(ThemePresenter())
        }
        else {
            self.delegate?.enableProvisioning()
        }
    }
    
    func provision(_ code: String) {
        if let _ = CommonProperties.provisioningCode.value as? String {
            return
        }
        
        if code.count == 0 {
            self.delegate?.provisioningFailed("Please enter a valid provisioning code.")
            return
        }

        self.delegate?.showSpinner("Provisioning account...")
        
        let dataSource = ProvisioningDataSource.init()
        dataSource.provision { (provision, error) in
            self.delegate?.hideSpinner()
            
            if let error = error {
                log.error(error)
                self.delegate?.provisioningFailed(error.localizedDescription)
                return
            }
            
            // - Provisioning request completed
            if let prov = provision, prov.title.count > 0, prov.url.absoluteString.count > 0 {
                log.debug("Provisioning completed successfully \(prov).")

                // - Update the common properties to store the code, title and base URL
                CommonProperties.provisioningCode.setValue(code)
                CommonProperties.servicesBasePath.setValue(prov.url.absoluteString)
                CommonProperties.title.setValue(prov.title)
                
                // - Update the view
                self.delegate?.provisioningSuccess(ThemePresenter.init())
            }
            else {
                CommonProperties.provisioningCode.remove()
                log.debug("Provisioning failed.")
                self.delegate?.provisioningFailed("The account could not be provisioned using code '\(code)'.")
            }
        }
    }
    
    func completeProvision() {
        self.delegate?.navigate("login", LoginPresenter())
    }
}
