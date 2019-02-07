//
//  AuthenticationDataSource.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class AuthenticationDataSource {
	let request: AuthenticateRequest

	init(_ username: String, _ password: String) {
		self.request = AuthenticateRequest.init(username: username, password: password)
	}

    func authenticate(_ onSuccess: @escaping () -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let success):
                    if success {
                        onSuccess()
                    }
                    else {
                        onFailure("Authentication failed.  Please enter a valid username and password.")
                    }
            }
        }
    }
}
