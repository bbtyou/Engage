//
//  WebViewDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import WebKit

protocol WebViewDelegate: class {
    
    // - Loads the url into the web view
    func load(withRequest urlRequest: URLRequest, _ title: String?)
    
    // - Loads the data in the web view
    func load(withData data: Data, _ pathExtension: String, _ title: String?)
    
    // - Displays an error message to the user if the content cannot be loaded
    func showError(_ message: String)
    
    // - Notify the view to disable share
    func disableShare()
    
    // - Notify the view to enable sharing
    func enableShare()
    
    // - Enables the web nav bar
    func enableNav()
    
    // - Disables the web nav bar
    func disableNav()
}
