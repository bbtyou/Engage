//
//  SupportViewController.swift
//  Engage
//
//  Created by Charles Imperato on 12/3/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class SupportViewController: EngageViewController {

    // - Outlets
    @IBOutlet fileprivate var emailView: UIView!
    @IBOutlet fileprivate var phoneView: UIView!
    @IBOutlet fileprivate var textView: UIView!
    @IBOutlet fileprivate var emailButton: UIButton!
    @IBOutlet fileprivate var phoneButton: UIButton!
    @IBOutlet fileprivate var textButton: UIButton!
    @IBOutlet fileprivate var supportTitleLabel: UILabel!
    @IBOutlet fileprivate var emailLabel: UILabel!
    @IBOutlet fileprivate var phoneLabel: UILabel!
    @IBOutlet fileprivate var textLabel: UILabel!
    @IBOutlet fileprivate var supportImageView: UIImageView!
    @IBOutlet fileprivate var emailImageView: UIImageView!
    @IBOutlet fileprivate var phoneImageView: UIImageView!
    @IBOutlet fileprivate var textImageView: UIImageView!
    
    // - Presenter for the view
    var presenter: RepSupportPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.theme()
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
        var view: UIView = self.emailView

        if sender == self.phoneButton {
            view = self.phoneView
        }
        else if sender == self.textButton {
            view = self.textView
        }
        
        view.clipsToBounds = false
    }
    
    @IBAction func touchDown(_ sender: UIButton) {
        var view: UIView = self.emailView
        
        if sender == self.phoneButton {
            view = self.phoneView
        }
        else if sender == self.textButton {
            view = self.textView
        }
        
        view.clipsToBounds = true

    }
}
