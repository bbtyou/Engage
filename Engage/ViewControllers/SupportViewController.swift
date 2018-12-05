//
//  SupportViewController.swift
//  Engage
//
//  Created by Charles Imperato on 12/3/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import MessageUI

class SupportViewController: EngageViewController {

    // - Outlets
    @IBOutlet fileprivate var emailView: UIView!
    @IBOutlet fileprivate var phoneView: UIView!
    @IBOutlet fileprivate var textView: UIView!
    @IBOutlet fileprivate var emailButton: UIButton!
    @IBOutlet fileprivate var phoneButton: UIButton!
    @IBOutlet fileprivate var textButton: UIButton!
    @IBOutlet fileprivate var emailLabel: UILabel!
    @IBOutlet fileprivate var phoneLabel: UILabel!
    @IBOutlet fileprivate var textLabel: UILabel!
    @IBOutlet fileprivate var supportImageView: UIImageView!
    @IBOutlet fileprivate var stackView: UIStackView!
    @IBOutlet fileprivate var emailImageView: UIImageView!
    @IBOutlet fileprivate var phoneImageView: UIImageView!
    @IBOutlet fileprivate var textImageView: UIImageView!
    
    // - Presenter for the view
    var presenter: SupportPresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    // - The error view
    fileprivate lazy var errorView: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = AppConfigurator.shared.themeConfigurator?.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // - Hide all views to start
        self.emailView.isHidden = true
        self.phoneView.isHidden = true
        self.textView.isHidden = true
        
        // Do any additional setup after loading the view.
        self.theme()
        
        // - Load the support
        self.presenter?.load()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // - Configure the state of the buttons
        self.drawShadows()
    }
}

// - Private
fileprivate extension SupportViewController {
    func theme() {
        let themeColor = AppConfigurator.shared.themeConfigurator?.themeColor ?? UIColor.gray

        // - Theme the main image
        self.supportImageView.image = self.supportImageView.image?.maskedImage(with: themeColor)
        
        // - Theme the button images
        self.emailImageView.image = self.emailImageView.image?.maskedImage(with: themeColor)
        self.phoneImageView.image = self.phoneImageView.image?.maskedImage(with: themeColor)
        self.textImageView.image = self.textImageView.image?.maskedImage(with: themeColor)
        
        // - Theme labels
        self.emailLabel.textColor = themeColor
        self.phoneLabel.textColor = themeColor
        self.textLabel.textColor = themeColor
        
        // - Set the background image
        self.view.backgroundColor = AppConfigurator.shared.themeConfigurator?.backgroundColor ?? UIColor.white
    }
    
    func drawShadows() {
        // Draw the shadows for the buttons
        let shadowedViews = [self.emailView, self.textView, self.phoneView]
        shadowedViews.forEach { (view) in
            guard let view = view else {
                return
            }
            
            DispatchQueue.main.async {
                let shadowPath = UIBezierPath.init(rect: view.bounds).cgPath
                view.layer.shadowColor = UIColor.darkGray.cgColor
                view.layer.shadowOffset = CGSize(width: 0, height: 1)
                view.layer.shadowOpacity = 1.0
                view.layer.shadowRadius = 1
                view.layer.shadowPath = shadowPath
                view.layer.masksToBounds = false
                view.clipsToBounds = false
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func touchUp(_ sender: UIButton) {
        self.phoneView.layer.shadowOpacity = 1
        self.textView.layer.shadowOpacity = 1
        self.emailView.layer.shadowOpacity = 1

        if sender == self.emailButton {
            self.presenter?.sendEmail()
        }
        else if sender == self.phoneButton {
            self.presenter?.phoneCall()
        }
        else {
            self.presenter?.sendText()
        }
    }
    
    @IBAction func touchDown(_ sender: UIButton) {
        if sender == self.emailButton {
            self.emailView.layer.shadowOpacity = 0
            self.phoneView.layer.shadowOpacity = 1
            self.textView.layer.shadowOpacity = 1
        }
        else if sender == self.phoneButton {
            self.emailView.layer.shadowOpacity = 1
            self.phoneView.layer.shadowOpacity = 0
            self.textView.layer.shadowOpacity = 1
        }
        else {
            self.emailView.layer.shadowOpacity = 1
            self.phoneView.layer.shadowOpacity = 1
            self.textView.layer.shadowOpacity = 0
        }
    }
}

// MARK: - SupportDelegate

extension SupportViewController: SupportDelegate {
    func showEmail(_ email: String) {
        self.emailView.isHidden = false
        self.emailLabel.text = email
    }
    
    func showPhone(_ phone: String) {
        self.phoneView.isHidden = false
        self.phoneLabel.text = phone
    }
    
    func showSMS(_ sms: String) {
        self.textView.isHidden = false
        self.textLabel.text = sms
    }
    
    func hideEmail() {
        self.emailLabel.text = nil
        self.emailView.removeFromSuperview()
    }
    
    func hidePhone() {
        self.phoneLabel.text = nil
        self.phoneView.removeFromSuperview()
    }
    
    func hideSMS() {
        self.textLabel.text = nil
        self.textView.removeFromSuperview()
    }
    
    func setImage(withName name: String) {
        let themeColor = AppConfigurator.shared.themeConfigurator?.themeColor ?? UIColor.gray
        self.supportImageView.image = UIImage.init(named: name)?.maskedImage(with: themeColor)
    }
    
    func showError(_ message: String) {
        // - Add the error view
        self.view.addSubview(self.errorView)
        self.errorView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.errorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.errorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.errorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // - Add the image view
        let themeColor = AppConfigurator.shared.themeConfigurator?.themeColor ?? UIColor.gray

        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = CommonImages.errorsignal.image?.maskedImage(with: themeColor)
        
        self.view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: self.errorView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.errorView.centerYAnchor, constant: -25.0).isActive = true
        
        let messageLabel = UILabel.init(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = AppConfigurator.shared.themeConfigurator?.bodyTextColor
        messageLabel.font = UIFont.init(name: "Helvetica-Medium", size: 20.0)
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        // - Add the label
        self.view.addSubview(messageLabel)
        messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8.0).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: self.errorView.leadingAnchor, constant: 8.0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: self.errorView.trailingAnchor, constant: -8.0).isActive = true
    }
    
    func hideError() {
        self.errorView.removeFromSuperview()
        self.errorView.removeConstraints(self.errorView.constraints)
    }
    
    func composeEmail(_ subject: String, _ recipients: [String], _ cc: [String], _ bcc: [String]) {
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController.init()
            composer.mailComposeDelegate = self
            composer.setSubject(subject)
            composer.setToRecipients(recipients)
            composer.setCcRecipients(cc)
            composer.setBccRecipients(bcc)
            
            self.present(composer, animated: true)
        }
        else {
            let alert = UIAlertController.init(title: "Email Account", message: "You must set up an email account on this device to use this feature.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func composeSMS(_ subject: String, _ recipients: [String]) {
        if MFMessageComposeViewController.canSendText() {
            let composer = MFMessageComposeViewController.init()
            composer.messageComposeDelegate = self
            composer.subject = subject
            composer.recipients = recipients
            
            self.present(composer, animated: true)
        }
        else {
            let alert = UIAlertController.init(title: "SMS Messaging", message: "Your device must be configured to send SMS messages to use this feature.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func phoneCall(_ number: String) {
        if let phoneUrl = URL.init(string: "tel://\(number)"), UIApplication.shared.canOpenURL(phoneUrl) {
            UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController.init(title: "Phone Call", message: "The phone call could not be made at this time.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setTitle(_ title: String) {
        self.title = title
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension SupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            log.error("The email could not be sent because an error occurred. \(error.localizedDescription).")
            
            controller.dismiss(animated: true) {
                let alert = UIAlertController.init(title: "Mail Send Error", message: "The email could not be sent. \(error.localizedDescription).", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return
        }
        
        controller.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                switch result {
                    case .sent:
                        self.notify(message: "Your message was sent successfully!", 2.0)
                    
                    case .failed:
                        self.notify(message: "Your message failed to send", 2.0)
                    
                    default:
                        break
                }
            })
        }
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension SupportViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                switch result {
                    case .sent:
                        self.notify(message: "Your message was sent successfully!", 2.0)
                    
                    case .failed:
                        self.notify(message: "Your message failed to send", 2.0)
                    
                    default:
                        break
                }
            })
        }

    }
}
