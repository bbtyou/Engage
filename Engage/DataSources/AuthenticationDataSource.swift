//
//  AuthenticationDataSource.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class AuthenticationDataSource: RestResponseCheckable {

	let request: AuthenticateRequest

	init(_ username: String, _ password: String) {
		self.request = AuthenticateRequest.init(username: username, password: password)
	}
	
	func authenticate(_ completion: @escaping (_ error: Error?) -> ()) {
		self.request.sendRequest { (response, data, error) in
			if let e = self.checkResponse(response, data, error) {
				completion(e)
				return
			}

			do {

				// - Check the response data for any login error information.  If successful then continue.  If a failure
				// - is detected then we provide as much error info to the user as possible.
				if let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
					if let success = json["success"] as? Bool, success == true {
						log.debug("Authentication completed successfully.")
						completion(nil)
					}
					else{
						log.warning("Authentication failed.")
						completion(AuthenticationError.authenticationFailure(msg: json["error"] as? String))
					}
				}
				else {
					completion(JSONError.notFound)
				}

			}
			catch {
				log.error(error)
				completion(error)
			}
			
		}
	}
}
