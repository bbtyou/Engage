//
//  ProvisioningDelgate.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol ProvisioningDelegate: class {
    
    // - Provisioining completed successfully with no errors and passes along the theme presenter
    func provisioningSuccess(_ tp: ThemePresenter)
    
    // - Provisioning failed with the given reason
    func provisioningFailed(_ message: String)
    
    // - Enables the provisioning view
    func enableProvisioning()
    
    // - Disables the provisioning view
    func disableProvisioning()
    
    // - Navigate to the next screen with the specified identifier
    func navigate(_ identifier: String, _ presenter: LoginPresenter)
    
}
