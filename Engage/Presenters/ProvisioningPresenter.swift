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
    
    func checkProvisioning() {
        if Current.code().count > 0 {
            self.delegate?.disableProvisioning()
            self.delegate?.provisioningSuccess(ThemePresenter())
        }
        else {
            self.delegate?.enableProvisioning()
        }
    }
    
    func provision(code: String) {
        if Current.code().count > 0 {
            return
        }
        
        if code.count == 0 {
            self.delegate?.provisioningFailed("Please enter a valid provisioning code.")
            return
        }
        
        (self.delegate as? Waitable)?.showSpinner("Provisioning your account...")
        
        Current.provisioning().provision(code) { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let prov):
                Properties.servicesBasePath.setValue(value: prov.url.absoluteString)
                Properties.title.setValue(value: prov.title)
                Properties.provisioningCode.setValue(value: code)
                self.delegate?.provisioningSuccess(ThemePresenter())
                
            case .failure(let error):
                self.delegate?.provisioningFailed(error.localizedDescription)
            }
        }
    }
    
    func completeProvision() {
        self.delegate?.navigate("login", LoginPresenter())
    }
}

