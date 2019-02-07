//
//  Request.swift
//  Engage
//
//  Created by Charles Imperato on 11/8/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit
import wvslib

struct AuthenticateRequest: Request {
    typealias T = Bool
    
    var username: String?
    var password: String?
    
    var id: String {
        get {
            return "authenticate"
        }
    }
    
    var relativePath: String {
        get {
            return "/api/authenticate"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    var body: HTTPParamaters? {
        get {
            var parameters = HTTPParamaters()
            parameters["login"] = self.username
            parameters["passwd"] = self.password
            
            return parameters
        }
    }
    
    var parameterEncoding: HTTPBodyEncoding {
        get {
            return .url
        }
    }
    
    func convertData(_ data: Data) -> Bool? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let success = json["success"] as? Bool, success == true {
                return true
            }
        }
        catch {
            log.error("Unable to retrieve the authentication response.  \(error.localizedDescription)")
        }
        
        return false
    }
}

struct ProfileRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "profile"
        }
    }
    
    var relativePath: String {
        get {
            return "/profile.json"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
}

struct CalendarRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "calendar"
        }
    }
    
    var relativePath: String {
        get {
            return "/calendar.json"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
}

struct PortalRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "portal_\(UUID.init().uuidString))"
        }
    }
    
    var relativePath: String {
        get {
            return "/portal.json"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
}

struct ThemeRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "theme"
        }
    }
    
    var relativePath: String {
        get {
            return "/theme.json"
        }
    }
    
    var method: httpMethod {
        get {
            return .get
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
}

struct ProvisionRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "provision"
        }
    }
    
    var basePath: String {
        get {
            return "https://perpetuitymd.com"
        }
    }
    
    var relativePath: String {
        get {
            return "/provision.json"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    var body: HTTPParamaters? {
        get {
            var parameters = HTTPParamaters()
            parameters["code"] = self.code
            return parameters
        }
    }
    
    var parameterEncoding: HTTPBodyEncoding {
        get {
            return .url
        }
    }
    
    // - The provisioning code
    var code: String = ""
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
}

struct LogoutRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "logout"
        }
    }
    
    var fullPath: String {
        get {
            if self.basePath.last == "/" {
                return "\(self.basePath.dropLast())\(self.relativePath)"
            }
            
            return "\(self.basePath)\(self.relativePath)"
        }
    }
    
    var relativePath: String {
        get {
            return "?task=logout"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
}

struct MarkMessageReadRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "markmessageread"
        }
    }
    
    var relativePath: String {
        get {
            return "/api/messageread"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    var body: HTTPParamaters? {
        get {
            var parameters = HTTPParamaters()
            parameters["id"] = self.messageId
            return parameters
        }
    }

    var parameterEncoding: HTTPBodyEncoding {
        get {
            return .url
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
    
    // - The ID for the message to be marked read
    let messageId: String
}

struct DeleteMessageRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "deletemessage"
        }
    }
    
    var relativePath: String {
        get {
            return "/api/messagedelete"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    var body: HTTPParamaters? {
        get {
            var parameters = HTTPParamaters()
            parameters["id"] = self.messageId
            return parameters
        }
    }
    
    var parameterEncoding: HTTPBodyEncoding {
        get {
            return .url
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
    
    // - The ID for the message to be deleted
    let messageId: String
}

struct SetFavoriteRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "setfavorite"
        }
    }
    
    var relativePath: String {
        get {
            return "/api/setfavorite"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }

    var body: HTTPParamaters? {
        get {
            var parameters = HTTPParamaters()
            parameters["id"] = self.unid
            return parameters
        }
    }
    
    var parameterEncoding: HTTPBodyEncoding {
        get {
            return .url
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
    
    let unid: String
}

struct UnsetFavoriteRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "unsetfavorite"
        }
    }
    
    var relativePath: String {
        get {
            return "/api/unsetfavorite"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }
    
    var body: HTTPParamaters? {
        get {
            var parameters = HTTPParamaters()
            parameters["id"] = self.unid
            return parameters
        }
    }
    
    var parameterEncoding: HTTPBodyEncoding {
        get {
            return .url
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
    
    let unid: String
}

struct PushRegisterRequest: Request {
    typealias T = Data
    
    var id: String {
        get {
            return "pushregister"
        }
    }
    
    var relativePath: String {
        get {
            return "/api/register"
        }
    }
    
    var method: httpMethod {
        get {
            return .post
        }
    }

    var body: HTTPParamaters? {
        get {
            var parameters = HTTPParamaters()
            parameters["id"] = self.token
            return parameters
        }
    }
    
    var parameterEncoding: HTTPBodyEncoding {
        get {
            return .url
        }
    }
    
    func convertData(_ data: Data) -> Data? {
        return data
    }
    
    let token: String
}

// MARK: - Form encoded dictionary
extension Dictionary {
    var urlEncoding: Data? {
        var output: String = ""
        
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        
        return output.dropLast().data(using: .utf8)
    }
    
    var jsonEncoding: Data? {
        if let json = try? JSONSerialization.data(withJSONObject: self) {
            return json
        }
        
        return nil
    }
}

