//
//  Request.swift
//  Engage
//
//  Created by Charles Imperato on 11/8/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

// - HTTP Method types
enum httpMethod: String {

    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"

}

// - HTTP body encoding for post requests
enum HTTPBodyEncoding {
    case json
    case url
}

// - Parameters for the request
typealias HTTPParamaters = [String: Any]

// - HTTP Headers
typealias HTTPHeaders = [String: String]

// MARK - Request types

protocol Request {
    
    // = The identifier of the request
    var id: String { get }
    
    // - The base path for this request
    var basePath: String { get }
    
    // - The relative path for this request
    var relativePath: String { get }
    
    // - The full path for this request
    var fullPath: String { get }
    
    // - HTTP method
    var method: httpMethod { get }

    // - HTTP Body
    var body: HTTPParamaters? { get }
    
    // - HTTP Headers
    var headers: HTTPHeaders? { get }
    
    // - Parameter encoding
    var parameterEncoding: HTTPBodyEncoding { get }
    
}

extension Request {

    var fullPath: String {
        get {
            return "\(self.basePath)\(self.relativePath)"
        }
    }
    
    var basePath: String {
        get {
            return CommonProperties.servicesBasePath.value as? String ?? ""
        }
    }
    
    var body: HTTPParamaters? {
        get {
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        get {
            return nil
        }
    }
    
    var parameterEncoding: HTTPBodyEncoding {
        return self.method == .get ? .url : .json
    }
    
    // - Send the request
    func sendRequest(timeout: TimeInterval = 20, useCache cache: Bool = true, _ completion: @escaping (_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> ()) {
        
        // - If this request is cacheable then attempt to retrieve from the cache
        let session = URLSession.shared

        // - Configure the session
        session.configuration.httpShouldSetCookies = true
        session.configuration.allowsCellularAccess = true
        session.configuration.httpMaximumConnectionsPerHost = 5
        session.configuration.urlCache = cache == true ? URLCache.shared : nil
        session.configuration.requestCachePolicy = cache == true ? .returnCacheDataElseLoad : .reloadIgnoringCacheData
        session.configuration.httpCookieAcceptPolicy = .always
        session.configuration.timeoutIntervalForRequest = timeout
        
        // - Create the request with the url
        guard let url = URL.init(string: self.fullPath) else {
            completion(nil, nil, RestClientError.invalidUrl)
            return
        }

        var request = URLRequest(url: url)
        
        // - Add additional headers
        self.headers?.forEach({ (header) in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        })
        
        // - Set the body parameters after proper encoding
        if let body = self.body {
            if self.parameterEncoding == .json, let bodyData = body.jsonEncoding {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = bodyData
            }
            else if let bodyData = body.urlEncoding {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = bodyData
            }
        }
        
        // - Set the http request method
        request.httpMethod = self.method.rawValue
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data, let cacheable = self as? Cacheable {
                cacheable.write(data)
            }
            
            DispatchQueue.main.async {
                completion(response as? HTTPURLResponse, data, error)
            }
        }
        
        task.taskDescription = self.id
    
        // - Add the task to the task manager
        RequestTaskManager.shared.addTask(task)
        
    }

    func cancel() {
        RequestTaskManager.shared.cancel(taskId: self.id)
    }
    
    func suspend() {
        RequestTaskManager.shared.suspend(taskId: self.id)
    }
}

struct ImageRequest: Request, Cacheable {
    var path: String = ""
    
    var id: String {
        get {
            return "imageRequest_\(UUID.init().uuidString)"
        }
    }
    
    var relativePath: String {
        get {
            var path: String = ""
            
            if self.path.starts(with: "/") {
                path = self.path.getSubstring(from: 1, to: nil) ?? self.path
            }
            else {
                path = self.path
            }
            
            return path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        }
    }
    
    var method: httpMethod {
        get {
            return .get
        }
    }
    
}

struct DownloadRequest: Request, Cacheable {
    var path = ""
    
    var id: String {
        get {
            return "downloadRequest_\(UUID.init().uuidString)"
        }
    }
    
    var relativePath: String {
        get {
            var path: String = ""
            
            if self.path.starts(with: "/") {
                path = self.path.getSubstring(from: 1, to: nil) ?? self.path
            }
            else {
                path = self.path
            }

            return path
        }
    }
    
    var method: httpMethod {
        get {
            return .get
        }
    }
}

struct AuthenticateRequest: Request {
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
}

struct ProfileRequest: Request {
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
}

struct CalendarRequest: Request {
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
}

struct PortalRequest: Request {
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
}

struct ThemeRequest: Request {
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
}

struct ProvisionRequest: Request {
    var id: String {
        get {
            return "provision"
        }
    }
    
    var basePath: String {
        get {
            return "https://myengageapp.com"
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
}

struct LogoutRequest: Request {
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
}

struct MarkMessageReadRequest: Request {
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
    
    // - The ID for the message to be marked read
    let messageId: String
}

struct DeleteMessageRequest: Request {
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
    
    // - The ID for the message to be deleted
    let messageId: String
}

struct SetFavoriteRequest: Request {
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
    
    let unid: String
}

struct UnsetFavoriteRequest: Request {
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
    
    let unid: String
}

struct PushRegisterRequest: Request {
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

