//
//  Error.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// MARK: - RestClientError
// - Rest service client errors are produced from network calls based on the HTTP Response
enum RestClientError: LocalizedError {
    case unknown
    case invalidRequest
    case forbidden
    case conflict
    case unauthorized
    case notFound
    case invalidUrl
    
    static func error(forCode code: Int) -> RestClientError {
        switch code {
            case 400:
                return .invalidRequest
            
            case 401:
                return .unauthorized
            
            case 403:
                return .forbidden
            
            case 404:
                return .notFound
            
            default:
                return .unknown
        }
    }
    
    var errorDescription: String? {
        get {
            switch self {
                case .conflict:
                    return "The request could not be completed due to a conflict with the current state of the resource."
                
                case .invalidRequest:
                    return "The request could not be understood by the server due to malformed syntax."
                
                case .unauthorized:
                    return "The request requires user authentication."
                
                case .forbidden:
                    return "The server understood the request, but is refusing to fulfill it."
                
                case .notFound:
                    return "The server has not found anything matching the Request."
                
                case .invalidUrl:
                    return "The request could not be completed because the URL was invalid."
                
                default:
                    return "An unknown error occurred when making the request."
            }
        }
    }
}

// MARK: - RestServerError
// - Rest server errors are produced from a response from the server resulting in invalid results
enum RestServerError: LocalizedError {
    case internalServerError
    case serviceUnavailable
    
    var errorDescription: String? {
        get {
            switch self {
                case .internalServerError:
                    return "The server encountered an unexpected condition which prevented it from fulfilling the request."
                
                case .serviceUnavailable:
                    return "The server is currently unable to handle the request due to a temporary overloading or maintenance of the server."
            }
        }
    }
}

// MARK: - JSONError
// - JSON errors are produced from invalid json operations resulting in invalid json data
enum JSONError: LocalizedError {
    case jsonObject(error: Error?)
    case jsonData(error: Error?)
    case exception(error: Error)
    case notFound
    
    var errorDescription: String? {
        switch self {
            case .jsonObject(let error):
                    return "The data could not be deserialized to a JSON object. \(error?.localizedDescription ?? "")"
            
            case .jsonData(let error):
                    return "The json object could not be serialized to data. \(error?.localizedDescription ?? "")"
        
            case .exception(let error):
                return error.localizedDescription
            
            case .notFound:
                return "The json object node could not be found."
        }
    }
}

// MARK: - Authentication
// - Authentication errors are produced when authentication could not be completed
enum AuthenticationError: LocalizedError {
	case authenticationFailure(msg: String?)

	var errorDescription: String? {
		switch self {
			case .authenticationFailure(let msg):
				if let message = msg {
					return message
				}
				
				return "Authentication failed.  Please try again or contact your system administrator if the problem persists."
		}
	}
}

// MARK: - WebRequest errors
// - Web request errors occur when there is a problem loading the web content
enum WebRequestError: LocalizedError {
    case invalidUrl
    case loadError(error: Error?)
    
    var errorDescription: String? {
        switch self {
            case .invalidUrl:
                return "The web request could not be completed because the url was invalid."
            
            case .loadError(let error):
                var message = "The web content failed to load."
                
                if let error = error {
                    message = message + " \(error.localizedDescription)."
                }
                
                return message
        }
    }
}
