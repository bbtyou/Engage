//
//  LoginViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, OrientationConfigurable {
    
    // MARK: - Outlets
    @IBOutlet fileprivate var usernameTextField: UITextField!
    @IBOutlet fileprivate var passwordTextField: UITextField!
    @IBOutlet fileprivate var loginButton: UIButton!
    @IBOutlet fileprivate var loginImageView: UIImageView!
    @IBOutlet fileprivate var errorLabel: UILabel!
    @IBOutlet fileprivate var adjustableConstraint: NSLayoutConstraint!
    
    // - Presenter
	var presenter: LoginPresenter? {
		didSet {
			self.presenter?.delegate = self
		}
	}
	
	// - Home presenter
	fileprivate weak var drawerPresenter: DrawerPresenter?
	
	// - Supported interface orientations
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return self.portraitForPhone
        }
    }
	
	// - Keyboard adjustment constraint
	fileprivate var keyboardAdjust: CGFloat {
		get {
			return UIDevice.current.sizeClass == .compact ? 60.0 : 120.0
		}
	}
	
	deinit {
		log.verbose("** Deallocated viewController \(LoginViewController.self).")
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loginButton?.style()

		self.usernameTextField.style()
		self.usernameTextField.delegate = self
		self.usernameTextField.text = "chuck@perpetuitymd.com"
        
        self.passwordTextField.style()
		self.passwordTextField.delegate = self
        self.passwordTextField.text = "guitar20"
        
        // - Hide the navigation bar for login
        self.navigationController?.isNavigationBarHidden = true
        
        // - Listen to keyboard events
        NotificationCenter.default.addObserver(
            self,
                selector: #selector(self.keyboardWillShow),
                    name: UIResponder.keyboardWillShowNotification,
                        object: nil)
        
        NotificationCenter.default.addObserver(
            self,
                selector: #selector(self.keyboardWillHide),
                    name: UIResponder.keyboardWillHideNotification,
                        object: nil)
    }
	
	// MARK: - Keyboard listener
	
	@objc func keyboardWillShow(_ notification: Notification) {
		if let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			let keyboardY = kbFrame.cgRectValue.origin.y
			let buttonY = self.loginButton.frame.origin.y + self.loginButton.frame.size.height
			if keyboardY <= buttonY {
				self.adjustableConstraint.constant = self.keyboardAdjust - ((buttonY - keyboardY) + 10.0)

				// - Animate into place
				UIView.animate(withDuration: 0.5) {
					self.view.layoutIfNeeded()
					self.loginImageView.alpha = 0
				}
			}
		}
	}
	
	@objc func keyboardWillHide(_ notification: Notification) {
		self.adjustableConstraint.constant = self.keyboardAdjust
		
		// - Animate into place
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
			self.loginImageView.alpha = 1.0
		}
	}
	
    // MARK: - Actions
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
	
	@IBAction func loginTapped(_ sender: UIButton) {
		self.view.endEditing(true)
		self.presenter?.login(self.usernameTextField.text, password: self.passwordTextField.text)
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let drawer = segue.destination as? DrawerViewController {
			drawer.presenter = self.drawerPresenter
		}
    }
}

// MARK: - LoginDelegate

extension LoginViewController: LoginDelegate {
    func loginCompleted() {
		log.debug("Authentication completed successfully.")
    }
    
    func loginFailed(_ message: String) {
        self.errorLabel.text = message
		
		// - Shake the controls
		self.usernameTextField.shake(.horizontal)
		self.passwordTextField.shake(.horizontal)
		self.loginButton.shake(.horizontal)
    }
	
	func navigate(_ identifier: String, _ presenter: DrawerPresenter) {
        self.drawerPresenter = presenter
		self.performSegue(withIdentifier: identifier, sender: self)
	}
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		self.errorLabel.text = nil
		return true
	}
}
