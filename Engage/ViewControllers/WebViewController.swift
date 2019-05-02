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
import wvslib

class WebViewController: UIViewController {
    
    // - Presenter
    var presenter: WebViewPresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    // - Web view
    fileprivate lazy var webView: WKWebView = {
        // - Config
        let config = WKWebViewConfiguration.init()
        
        // - Create the user content controller
        let userContentController = WKUserContentController.init()
        userContentController.add(self, name: "wkPost")
        config.userContentController = userContentController
        
        let web = WKWebView.init(frame: .zero, configuration: config)
        web.translatesAutoresizingMaskIntoConstraints = false
        web.backgroundColor = UIColor.clear
        web.configuration.allowsInlineMediaPlayback = true
        web.navigationDelegate = self
        web.uiDelegate = self
        return web
    }()
    
    // - Navigation bar
    fileprivate lazy var webNavBar: UIView = {
        let view = UIView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = self.backgroundColor

        return view
    }()
    
    // - Back button for web view
    fileprivate lazy var webBackButton: UIButton = {
        let back = UIButton.init(type: .custom)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.backgroundColor = UIColor.clear
        back.isHidden = true
        back.setImage(CommonImages.goback.image?.maskedImage(with: self.themeColor), for: .normal)
        back.addTarget(self, action: #selector(webBack), for: .touchUpInside)
        return back
    }()

    // - Back button label
    fileprivate lazy var webBackButtonLabel: UILabel = {
        let backLabel = UILabel.init()
        backLabel.translatesAutoresizingMaskIntoConstraints = false
        backLabel.isHidden = true
        backLabel.font = UIFont.init(name: "Helvetica", size: 13.0)
        backLabel.textColor = self.themeColor
        backLabel.text = "Go Back"
        return backLabel
    }()
    
    // - Reload button for web view
    fileprivate lazy var webReloadButton: UIButton = {
        let reload = UIButton.init(type: .custom)
        reload.translatesAutoresizingMaskIntoConstraints = false
        reload.backgroundColor = UIColor.clear
        reload.setImage(CommonImages.reload.image?.maskedImage(with: self.themeColor), for: .normal)
        reload.addTarget(self, action: #selector(webReload), for: .touchUpInside)
        return reload
    }()

    // - Height constraint for the nav bar
    fileprivate var webNavBarHeight: NSLayoutConstraint?
    
    // - The data which can be shared
    var shareData: Data?

    // - Supported share types
    var supportedShareTypes: [ShareType] = [.email, .print]
    
    // - The optional body of the shareable
    var body: String?
    
    // - The mime type of the shareable data
    var mimeType: String?
    
    // - The subject of the shareable
    var subject: String?

    // - The name of the share
    var name: String?
    
    // - Notifiable
    var notifyContainer: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // - Layout constraints
        self.layout()
        
        self.presenter?.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.webNavBar.isHidden {
            return
        }
        
        let shadowPath = UIBezierPath.init(rect: self.webNavBar.bounds).cgPath
        self.webNavBar.layer.shadowColor = UIColor.darkGray.cgColor
        self.webNavBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.webNavBar.layer.shadowOpacity = 1.0
        self.webNavBar.layer.shadowRadius = 1
        self.webNavBar.layer.shadowPath = shadowPath
        self.webNavBar.layer.masksToBounds = false
        self.webNavBar.layer.masksToBounds = false
        self.webNavBar.clipsToBounds = false
    }
    
    deinit {
        Current.log().verbose("** Deallocated viewController \(WebViewController.self).")
    }
    
    // - Actions
    
    @objc fileprivate func shareTapped(_ sender: UIBarButtonItem) {
        self.share()
    }
    
    @objc fileprivate func webBack() {
        self.webView.goBack()
    }
    
    @objc fileprivate func webReload() {
        self.showSpinner("Reloading \(self.title ?? "page")...")
        self.webView.reloadFromOrigin()
    }
}

// MARK: - WebViewDelegate

extension WebViewController: WebViewDelegate {

    func load(withRequest urlRequest: URLRequest, _ title: String?) {
        self.title = title
        self.webView.load(urlRequest)
    }
    
    func load(html: String, _ baseUrl: URL?, _ title: String?) {
        self.title = title
        self.webView.loadHTMLString(html, baseURL: baseUrl)
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
        
        // - Set the name of the shared data
        self.name = title
        
        // - Set the data used for share
        self.shareData = data
        
        // - Set the mimetype
        self.mimeType = MimeMap.shared.mime(forExtension: pathExtension)
        
        // - Since WKWebView has issues loading from data even with the specified mime type, we create a temporary file to write the data to and load it
        let fm = FileManager.default
        let tempFileUrl = fm.temporaryDirectory.appendingPathComponent("temp").appendingPathExtension(pathExtension)
        Current.log().debug("loading file from \(tempFileUrl) into web view.")

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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "share")?.maskedImage(with: themeColor), style: .plain, target: self, action: #selector(shareTapped(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = themeColor
    }
    
    func disableShare() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func enableNav() {
        self.webNavBarHeight?.constant = 44.0
        self.webNavBar.isHidden = false
    }
    
    func disableNav() {
        self.webNavBarHeight?.constant = 0
        self.webNavBar.isHidden = true
    }
}

// - MARK: WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideSpinner()
        
        if self.title == nil {
            webView.evaluateJavaScript("document.title") { (title, error) in
                if let title = title as? String {
                    self.title = title
                }
            }
        }
        
        self.webBackButton.isHidden = !webView.canGoBack
        self.webBackButtonLabel.isHidden = !webView.canGoBack
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
        
        Current.log().error(WebRequestError.loadError(error: error))
        self.showError(WebRequestError.loadError(error: error).localizedDescription)

        if self.title == nil {
            webView.evaluateJavaScript("document.title") { (title, error) in
                if let title = title as? String {
                    self.title = title
                }
            }
        }
        
        self.webBackButton.isHidden = !webView.canGoBack
        self.webBackButtonLabel.isHidden = !webView.canGoBack
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        let base = CommonProperties.servicesBasePath.value as? String ?? ""
        
        Current.log().verbose("Request: \(request)")
        
        // - Handle any links that are outside of the application domain.
        // - These links should be opened in an external browser.
        if let url = request.url, navigationAction.navigationType == .linkActivated, let host = url.host, base.contains(host) == false {
            // - If the application can open the url then open it externally
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else {
                Current.log().warning("Unable to open external link: \(url.absoluteString).")
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
        else if let url = request.url, let host = url.host, base.contains(host) == false {
            decisionHandler(.allow)
        }
        else if let url = request.url, url.absoluteString.contains("blank") {
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.cancel)
            self.presenter?.loadRedirectRequest(fromRequest: request)
        }
    }
}

// MARK: - WKWebViewUIDelegate

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        if let target = navigationAction.targetFrame?.isMainFrame, target == false {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
}

// MARK: - WKScriptMessageHandler

extension WebViewController: WKScriptMessageHandler {    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // - Process the body
        self.presenter?.loadPagePost(message.body)
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

// MARK: - MFMessageComposeViewControllerDelegate

extension WebViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
    }
}

// MARK: - Themeable

extension WebViewController: Themeable {}

// MARK: - Notifiable

extension WebViewController: Notifiable {}

// MARK: - Waitable

extension WebViewController: Waitable {}

// MARK: - Shareable

extension WebViewController: Shareable {}

// MARK: - Popoverpresentationdelegate

extension WebViewController: UIPopoverPresentationControllerDelegate {}

// MARK: - Private

fileprivate extension WebViewController {
    func layout() {
        // - Add the nav view
        self.view.addSubview(self.webNavBar)
        
        self.webNavBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webNavBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webNavBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.webNavBarHeight = self.webNavBar.heightAnchor.constraint(equalToConstant: 44.0)
        self.webNavBarHeight?.isActive = true
        
        // - Add the buttons to the nav bar
        self.webNavBar.addSubview(self.webBackButton)
        
        self.webBackButton.leadingAnchor.constraint(equalTo: self.webNavBar.leadingAnchor, constant: 17.0).isActive = true
        self.webBackButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        self.webBackButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        self.webBackButton.centerYAnchor.constraint(equalTo: self.webNavBar.centerYAnchor).isActive = true
        
        self.webNavBar.addSubview(self.webReloadButton)
        
        self.webReloadButton.trailingAnchor.constraint(equalTo: self.webNavBar.trailingAnchor, constant: -17.0).isActive = true
        self.webReloadButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        self.webReloadButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        self.webReloadButton.centerYAnchor.constraint(equalTo: self.webNavBar.centerYAnchor).isActive = true
        
        // - Add the web view
        self.view.addSubview(self.webView)
        
        self.webView.topAnchor.constraint(equalTo: self.webNavBar.bottomAnchor, constant: 1.0).isActive = true
        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // - Add the labels
        self.webNavBar.addSubview(self.webBackButtonLabel)
        
        self.webBackButtonLabel.leadingAnchor.constraint(equalTo: self.webBackButton.trailingAnchor, constant: 8.0).isActive = true
        self.webBackButtonLabel.centerYAnchor.constraint(equalTo: self.webBackButton.centerYAnchor).isActive = true
        
        let reloadLabel = UILabel.init()
        reloadLabel.translatesAutoresizingMaskIntoConstraints = false
        reloadLabel.font = UIFont.init(name: "Helvetica", size: 13.0)
        reloadLabel.textColor = self.themeColor
        reloadLabel.text = "Reload"
        
        self.webNavBar.addSubview(reloadLabel)
        reloadLabel.trailingAnchor.constraint(equalTo: self.webReloadButton.leadingAnchor, constant: -8.0).isActive = true
        reloadLabel.centerYAnchor.constraint(equalTo: self.webReloadButton.centerYAnchor).isActive = true
    }
}
