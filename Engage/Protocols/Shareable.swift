//
//  Shareable.swift
//  Engage
//
//  Created by Charles Imperato on 11/27/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import MessageUI
import MobileCoreServices

// - Protocol defining an object that can print or email contents
protocol Shareable {
    
    // - The data which can be shared
    var shareData: Data? { get }
    
    // - The mime type of the shareable data
    var mimeType: String? { get }
    
}

fileprivate extension Shareable where Self: UIViewController {

    // - Private
    fileprivate func showError(_ message: String) {
        let alert = UIAlertController.init(title: "Share Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        
        // - Present the alert error
        self.present(alert, animated: true, completion: nil)
    }

}

extension Shareable where Self: (UIViewController & UIPopoverPresentationControllerDelegate & MFMailComposeViewControllerDelegate) {
    
    func share() {
        // - Create the action sheet to handle share
        let shareMenu = UIAlertController.init(title: "Share", message: nil, preferredStyle: .actionSheet)
        let email = UIAlertAction.init(title: "Email", style: .default) { (action) in
            if MFMailComposeViewController.canSendMail() {
                self.email()
            }
            else {
                let alert = UIAlertController.init(title: "Email Account",
                                message: "You must set up an email account on this device to use this feature.",
                                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        shareMenu.addAction(email)
        
        if let data = self.shareData, UIPrintInteractionController.canPrint(data) {
            let print = UIAlertAction.init(title: "Print", style: .default) { (action) in
                self.print()
            }
            
            shareMenu.addAction(print)
        }
        
        shareMenu.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        // - Display the share menu as a popover for iPads and an action sheet for phones
        if UIDevice.current.sizeClass == .regular {
            shareMenu.modalPresentationStyle = .popover
            
            let popover = shareMenu.popoverPresentationController
            popover?.permittedArrowDirections = .any
            popover?.barButtonItem = self.navigationItem.rightBarButtonItem
            popover?.delegate = self
        }
        
        self.present(shareMenu, animated: true, completion: nil)
    }
    
    // - This option shows up only if the data can be printed.
    // - Enabled air print printers can be used.
    func print() {
        let printInfo = UIPrintInfo.init(dictionary: nil)
        printInfo.jobName = self.title ?? "Document"
        printInfo.outputType = .general
        
        let controller = UIPrintInteractionController.shared
        controller.printInfo = printInfo
        controller.showsNumberOfCopies = false
        controller.printingItem = self.shareData
        
        if UIDevice.current.sizeClass == .regular, let barButton = self.navigationItem.rightBarButtonItem {
            controller.present(from: barButton, animated: true, completionHandler: nil)
        }
        else {
            controller.present(animated: true, completionHandler: nil)
        }
    }

    // - The document is attached to an email with the subject set as the document title
    func email() {
        guard let attachment = self.shareData, let mime = self.mimeType, let name = self.title else {
            let message = "Unable to email this document because the data could not be composed as an attachment."
            log.warning(message)
            self.showError(message)
            return
        }
        
        let composer = MFMailComposeViewController.init()
        composer.mailComposeDelegate = self
        composer.addAttachmentData(attachment, mimeType: mime, fileName: name.appending(".\(MimeMap.shared.pathExtension(forMime: mime))"))
        composer.setSubject(name)
        
        // - Present the email
        self.present(composer, animated: true, completion: nil)
    }
    
}
