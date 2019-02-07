//
//  ProvisioningViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/11/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import wvslib

class ProvisioningViewController: UIViewController, OrientationConfigurable {
    
    // MARK: - Outlets
    @IBOutlet fileprivate var provisioningCodeTextField: UITextField!
    @IBOutlet fileprivate var provisionButton: UIButton!
    @IBOutlet fileprivate var welcomeLabel: UILabel!
    @IBOutlet fileprivate var instructionLabel: UILabel!
    @IBOutlet fileprivate var errorLabel: UILabel!
	@IBOutlet fileprivate var logoImageView: UIImageView!
    @IBOutlet fileprivate var iconImageView: UIImageView!
    
    // - Presenter
    let presenter = ProvisioningPresenter()
    
    // - Chained presenters
    fileprivate var loginPresenter: LoginPresenter?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return self.portraitForPhone
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter.delegate = self
        
        // - Do not show the nav bar for the provisioning view
        self.navigationController?.isNavigationBarHidden = true
        
        // - Style the button
        self.provisionButton.style()
        
        // - Styled text field
        self.provisioningCodeTextField.delegate = self
        self.provisioningCodeTextField.style()

		// - Check if provisioning is needed
		self.presenter.migrate()
	}
	
    // MARK: - Actions
    
    @IBAction func provisionTapped(_ sender: UIButton) {
        let code = self.provisioningCodeTextField.text ?? ""
        self.view.endEditing(true)
        self.presenter.provision(code)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let rootNav = segue.destination as? RootNavigationController {
            rootNav.loginPresenter = self.loginPresenter
        }
    }
}

// MARK: - ProvisioningDelegate

extension ProvisioningViewController: ProvisioningDelegate {
    func provisioningSuccess(_ tp: ThemePresenter) {
        tp.delegate = self
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			tp.loadTheme()
		}
    }
    
    func provisioningFailed(_ message: String) {
        self.errorLabel.text = message
        self.provisioningCodeTextField.becomeFirstResponder()
    }
    
    func enableProvisioning() {
        self.iconImageView.isHidden = false
		self.logoImageView.isHidden = false
        self.provisioningCodeTextField.isHidden = false
        self.provisionButton.isHidden = false
        self.errorLabel.isHidden = false
        self.instructionLabel.isHidden = false
        self.welcomeLabel.isHidden = false
    }
    
    func disableProvisioning() {
        self.iconImageView.isHidden = true
		self.logoImageView.isHidden = true
        self.provisioningCodeTextField.isHidden = true
        self.provisionButton.isHidden = true
        self.errorLabel.isHidden = true
        self.instructionLabel.isHidden = true
        self.welcomeLabel.isHidden = true
    }
    
    func navigate(_ identifier: String, _ presenter: LoginPresenter) {
        self.loginPresenter = presenter
        self.performSegue(withIdentifier: identifier, sender: self)
    }
}

// MARK: - ThemeDelegate

extension ProvisioningViewController: ThemeDelegate {
    func themeFailed() {
        let alert = UIAlertController.init(title: "Theme Loading Failure", message: "The theme could not be loaded due to an unexpected error.  The default theme will be used.", preferredStyle: .alert)
		let ok = UIAlertAction.init(title: "OK", style: .default) { (action) in
			self.presenter.completeProvision()
		}
		
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    func themeLoaded() {
        self.presenter.completeProvision()
    }
}

// MARK: - TextFieldDelegate

extension ProvisioningViewController: UITextFieldDelegate {
    // - Clear the error if we begin typing a new provisioning code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text.count > 0 {
            self.errorLabel.text = nil
        }
        
        return true
    }
}
