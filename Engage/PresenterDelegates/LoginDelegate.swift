//
//  LoginDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol LoginDelegate: Waitable {
    
    // - Authentication completed successfully
    func loginCompleted()
	
    // - Authentication failed
    func loginFailed(_ message: String)

	// - Navigate to the next screen with the specified identifier
	func navigate(_ identifier: String, _ presenter: DrawerPresenter)

}
