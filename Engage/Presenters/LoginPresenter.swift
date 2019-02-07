//
//  LoginPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class LoginPresenter {
    
    weak var delegate: LoginDelegate?
    
    func login(_ username: String?, password: String?) {
		guard let username = username, let password = password else {
			self.delegate?.loginFailed("A valid username and password must be specified.  Please try again.")
			return
		}
		
		self.delegate?.showSpinner("Logging in...")
		
		let dataSource = AuthenticationDataSource.init(username, password)
        dataSource.authenticate({
            self.delegate?.hideSpinner()
            
            var userData = UserData()
            userData.password = password
            userData.userId = username
            
            AppConfigurator.shared.userInfo = userData
            
            self.delegate?.loginCompleted()
            
            // - Save the username
            CommonProperties.userid.setValue(username)
            
            // - Navigate to the home screen
            self.delegate?.navigate("home", DrawerPresenter())
            
            // - Notify listeners that login has completed
            NotificationCenter.default.post(name: NSNotification.Name.init("loginCompleted"), object: nil)
        }) { (error) in
            self.delegate?.hideSpinner()
            self.delegate?.loginFailed(error)
        }
    }
}
