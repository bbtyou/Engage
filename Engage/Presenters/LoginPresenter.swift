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
		
		(self.delegate as? Waitable)?.showSpinner("Logging in...")
		
        CurrentLocal.auth().authenticate(username, password, { result in
            (self.delegate as? Waitable)?.hideSpinner()

            switch result {
            case .success(let login):
                if let success = login.success, success == true {
                    // - Notify listeners that login has completed
                    NotificationCenter.default.post(name: NSNotification.Name.init("loginCompleted"), object: nil)
                    self.delegate?.loginCompleted()
                    self.delegate?.navigate("home", DrawerPresenter())
                }
                else {
                    self.delegate?.loginFailed(login.failure ?? "The system was unable to log you in.  Please contact your administrator for assistance.")
                }
                
            case .failure(let error):
                self.delegate?.loginFailed(error.localizedDescription)
            }
        })
    }
	
    
}
