//
//  WebViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class WebViewController: UIViewController, UIPopoverPresentationControllerDelegate, Shareable {
    
    // - Presenter
    var presenter: WebViewPresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    // - Web view
    fileprivate let webView = WKWebView()
    
    // - Shareable data
    internal var shareData: Data?
    
    // - Mimetype for the opened data
    internal var mimeType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView.navigationDelegate = self
        
        // - Set webview configuration
        self.webView.configuration.allowsInlineMediaPlayback = true
        
        // - Add the web view
        self.view.addSubview(self.webView)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.load()
    }
    
    deinit {
        log.verbose("** Deallocated viewController \(WebViewController.self).")
    }
    
    // - Actions
    
    @objc fileprivate func shareTapped(_ sender: UIBarButtonItem) {
        self.share()
    }
}

// MARK: - WebViewDelegate

extension WebViewController: WebViewDelegate {

    func load(withRequest urlRequest: URLRequest, _ title: String?) {
        self.title = title
        self.webView.load(urlRequest)
    }
    
    func showError(_ message: String) {
        
        let alert = UIAlertController.init(title: "Content Loading Error", message: message, preferredStyle: .alert)
        let close = UIAlertAction.init(title: "Close", style: .cancel) { [weak self] (action) in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(close)
        self.present(alert, animated: true)
    }
    
    func load(withData data: Data, _ pathExtension: String, _ title: String?) {
        self.title = title
        
        // - Set the data used for share
        self.shareData = data
        
        // - Set the mimetype
        self.mimeType = MimeMap.shared.mime(forExtension: pathExtension)
        
        // - Since WKWebView has issues loading from data even with the specified mime type, we create a temporary file to write the data to and load it
        let fm = FileManager.default
        let tempFileUrl = fm.temporaryDirectory.appendingPathComponent("temp").appendingPathExtension(pathExtension)
        log.debug("loading file from \(tempFileUrl) into web view.")

        do {
            // - Write to temp before loading
            try data.write(to: tempFileUrl)
            self.webView.loadFileURL(tempFileUrl, allowingReadAccessTo: tempFileUrl)
        }
        catch {
            self.showError("The content you requested could not be loaded at this time.  Please try again later or contact your system administrator if the problem persists: \(error).")
        }
    }
    
    func enableShare() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareTapped(_:)))
    }
    
    func disableShare() {
        self.navigationItem.rightBarButtonItem = nil
    }
}

// - MARK: WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideSpinner()
        
        if self.title == nil {
            webView.evaluateJavaScript("document.title") { (title, error) in
                if let title = title as? String {
                    self.title = title
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideSpinner()
        
        // -
        // - Do not handle these errors
        // -
        let unhandledError = error as NSError
        if unhandledError.domain == "WebKitErrorDomain" {
            switch unhandledError.code {
                case 102, 204:
                    return
                
                default:
                    break
            }
        }
        // -
        // - End unhandled errors
        // -
        
        log.error(WebRequestError.loadError(error: error))
        self.showError(WebRequestError.loadError(error: error).localizedDescription)

        if self.title == nil {
            webView.evaluateJavaScript("document.title") { (title, error) in
                if let title = title as? String {
                    self.title = title
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        let base = CommonProperties.servicesBasePath.value as? String ?? ""

        // - Handle any links that are outside of the application domain.
        // - These links should be opened in an external browser.
        if let url = request.url, navigationAction.navigationType == .linkActivated, let host = url.host, base.contains(host) == false {
            // - If the application can open the url then open it externally
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else {
                log.warning("Unable to open external link: \(url.absoluteString).")
            }
            
            decisionHandler(.cancel)
            return
        }
        
        // - If we are loading data from a file pass through
        if let local = request.url?.absoluteString.contains("localhost"), local == true {
            decisionHandler(.allow)
        }
        else if let _ = request.value(forHTTPHeaderField: "appBundleId") {
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.cancel)
            self.presenter?.loadRedirectRequest(fromRequest: request)
        }
    }
}

// MARK: - MFMailComposeDelegate

extension WebViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var message: String?
        
        switch result {
            case .failed:
                message = "This document could not be sent. \(error?.localizedDescription ?? "")"
            
            case .sent:
                fallthrough
            
            default:
                break
        }
        
        // - Notify the user that the email was sent
        controller.dismiss(animated: true) {
            if let message = message {
                let alert = UIAlertController.init(title: "Email Share", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
}
