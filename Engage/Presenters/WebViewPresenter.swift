//
//  WebViewPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class WebViewPresenter {
    
    // - MVP delegate (view) for the presenter
    weak var delegate: WebViewDelegate?
    
    // - Title
    fileprivate var title: String?
    
    // - Path for the item to be opened
    fileprivate var path: String?

    // - File URL
    fileprivate var fileUrl: URL?
    
    // - Data contents to be loaded
    fileprivate var data: Data?
    
    // - File extension type for opening files
    fileprivate var pathExtension: String?
    
    // - Navigation policy based on business needs
    fileprivate var allowPolicy: Bool = false
    
    init(withPath path: String, _ title: String? = nil) {
        self.path = path
        self.title = title
    }
    
    init(withData data: Data, _ pathExtension: String, _ title: String? = nil) {
        self.data = data
        self.pathExtension = pathExtension
        self.title = title
    }
    
    func load() {
        // - Handle the different types of content to be loaded
        if let data = self.data, let pathExtension = self.pathExtension {
            self.delegate?.disableNav()
            self.delegate?.enableShare()
            self.delegate?.load(withData: data, pathExtension, self.title)
            return
        }
        
        // - Load a web request
        var url: URL?
        
        guard let path = self.path?.lowercased() else {
            self.delegate?.showError("The specified url was invalid.")
            return
        }
        
        if path.starts(with: "http://") || path.starts(with: "https://") {
            url = URL.init(string: path)
        }
        else if let base = CommonProperties.servicesBasePath.value as? String {
            var trimmedPath = path
            
            if path.starts(with: "/"), let newPath = path.getSubstring(from: 1, to: nil) {
                trimmedPath = newPath
            }
            
            url = URL.init(string: "\(base)\(trimmedPath)")
        }

        guard let requestUrl = url else {
            self.delegate?.showError("The specified url was invalid.")
            return
        }
        
        // - Build the request to be sent to the web view
        var request = URLRequest.init(url: requestUrl)
        request.httpShouldHandleCookies = true
        request.addValue("appBundleId", forHTTPHeaderField: "appBundleId")
        request.timeoutInterval = 10
        
        // Add the cookies
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
        
        cookieHeaders.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let title = self.title {
            self.delegate?.showSpinner("Loading \(title) content...")
        }
        else {
            self.delegate?.showSpinner("Loading content...")
        }

        self.delegate?.enableNav()
        self.delegate?.load(withRequest: request, self.title)
    }
    
    func loadRedirectRequest(fromRequest request: URLRequest) {
        guard let url = request.url else {
            self.delegate?.showError("The web content could not be loaded.  Tap retry to try again or cancel to try again later.")
            return
        }
        
        // - Create a new request
        var newRequest = URLRequest.init(url: url)
        
        // - Copy all headers
        request.allHTTPHeaderFields?.forEach({ (header) in
            newRequest.setValue(header.value, forHTTPHeaderField: header.key)
        })
        
        newRequest.addValue("appBundleId", forHTTPHeaderField: "appBundleId")
        newRequest.httpMethod = request.httpMethod
        newRequest.httpBody = request.httpBody
        newRequest.httpShouldHandleCookies = true
        newRequest.timeoutInterval = 20

        // Add the cookies
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
        
        cookieHeaders.forEach { (key, value) in
            newRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        if let title = self.title {
            self.delegate?.showSpinner("Loading \(title) content...")
        }
        else {
            self.delegate?.showSpinner("Loading content...")
        }

        self.delegate?.load(withRequest: newRequest, self.title)
    }
    
    func loadPagePost(_ postMessageBody: Any) {
        
        do {
            // - Convert the json to a Data object
            let data = try JSONSerialization.data(withJSONObject: postMessageBody, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            
            // - Decode to a Post struct
            let post = try JSONDecoder.init().decode(WKPost.self, from: data)
            log.debug("Decoded post object: \(post)")
            
            // - Create the new request
            var url = post.url
            
            if post.url.starts(with: "/"), let base = CommonProperties.servicesBasePath.value as? String {
                url = base.dropLast().appending(url)
            }
            
            // - Construct the request
            guard let requestUrl = URL.init(string: url) else {
                log.warning("The web page could not be loaded because the url was invalid.")
                //TODO: Show error
                return
            }

            // - Construct the post body
            var postBody = ""
            for index in 0...post.post.count - 1 {
                postBody.append(contentsOf: "\(post.post[index].name)=\(post.post[index].value)")
                if index < post.post.count - 1 && post.post.count > 1 {
                    postBody += "&"
                }
            }
            
            log.verbose("The resulting post body: \(postBody)")
            
            // - Create the new request
            var request = URLRequest.init(url: requestUrl)
            request.httpMethod = "POST"
            request.httpBody = postBody.data(using: .utf8)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            self.loadRedirectRequest(fromRequest: request)
        }
        catch {
            log.error("Unable to navigate to the specified page due to an invalid post body. \(error)")
            self.delegate?.showError(error.localizedDescription)
        }
    }
}

fileprivate extension WebViewPresenter {
    // - Codable structs for retrieval
    fileprivate struct Post: Codable {
        // - Name of the parameter
        let name: String
        
        // - Value of the parameter
        let value: String
    }
    
    fileprivate struct WKPost: Codable {
        // - Post parameters
        let post: [Post]
        
        // - Relative url
        let url: String
    }
}
