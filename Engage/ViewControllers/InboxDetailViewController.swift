//
//  InboxDetailViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/22/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit
import wvslib

class InboxDetailViewController: UIViewController {
    
    // Notifiable
    var notifyContainer: UIView?
    
    // MARK: - Outlets
    
    @IBOutlet fileprivate var contentView: UIView!
    @IBOutlet fileprivate var profilePhotoImageView: UIImageView!
    @IBOutlet fileprivate var dateLabel: UILabel!
    @IBOutlet fileprivate var fromLabel: UILabel!
    @IBOutlet fileprivate var subjectLabel: UILabel!
    @IBOutlet fileprivate var bodyTextView: UITextView!
    @IBOutlet fileprivate var bottomConstraint: NSLayoutConstraint!
    
    // - Presenter for the view
    var presenter: InboxDetailPresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.sizeClass == .regular ? .all : .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // - Set the font and text styles
        self.dateLabel?.textColor = self.bodyTextColor
        self.fromLabel?.textColor = self.headerTextColor
        self.subjectLabel?.textColor = self.headerTextColor
        self.bodyTextView?.textColor = self.bodyTextColor
        
        // - Update the background
        self.view.backgroundColor = self.backgroundColor

        // - Update the photo image view
        self.profilePhotoImageView.image = self.profilePhotoImageView.image?.maskedImage(with: self.themeColor)
        self.profilePhotoImageView?.backgroundColor = self.backgroundColor
        
        // - Load the contents
        self.presenter?.load()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Draw the shadow for the content view
        let shadowPath = UIBezierPath.init(rect: self.contentView.bounds).cgPath
        self.contentView.layer.shadowColor = UIColor.darkGray.cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.contentView.layer.shadowOpacity = 1.0
        self.contentView.layer.shadowRadius = 1
        self.contentView.layer.shadowPath = shadowPath
        self.contentView.layer.masksToBounds = false
        self.contentView.clipsToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.bodyTextView.animateScrollViewBound(.vertical)
        self.bodyTextView.flashScrollIndicators()
    }
    
    deinit {
        Current.log().verbose("** Deallocated viewController \(InboxDetailViewController.self).")
    }
}

// MARK: - InboxDetailDelegate

extension InboxDetailViewController: InboxDetailDelegate {
    func detailsLoadComplete(_ details: InboxDetail) {
        self.dateLabel.text = details.date
        self.fromLabel.text = details.author
        self.bodyTextView.text = details.body
        self.subjectLabel.text = details.subject
        self.title = details.subject
    }
}

// MARK: - Themable

extension InboxDetailViewController: Themeable {}

// MARK: - Notifiable

extension InboxDetailViewController: Notifiable {}
