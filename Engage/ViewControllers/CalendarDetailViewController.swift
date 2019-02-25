//
//  CalendarDetailViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/24/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class CalendarDetailViewController: UIViewController {

    // - Outlets
    
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var dateLabel: UILabel!
    @IBOutlet fileprivate var topicLabel: UILabel!
    @IBOutlet fileprivate var additionalInfoLabel: UILabel!
    @IBOutlet fileprivate var bodyTextView: UITextView!
    @IBOutlet fileprivate var contentView: UIView!
    
    // - Presenter
    var presenter: CalendarDetailPresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // - Update the style for the theme
        self.view.backgroundColor = self.backgroundColor
        self.timeLabel.textColor = self.bodyTextColor
        self.dateLabel.textColor = self.bodyTextColor
        self.topicLabel.textColor = self.headerTextColor
        self.additionalInfoLabel.textColor = self.headerTextColor
        self.bodyTextView.textColor = self.bodyTextColor
        
        // - Load the detail and complete any business logic
        self.presenter?.loadDetail()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // - Shadow the content view
        let shadowPath = UIBezierPath.init(rect: self.contentView.bounds).cgPath
        
        self.contentView.layer.shadowColor = UIColor.darkGray.cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.contentView.layer.shadowOpacity = 1.0
        self.contentView.layer.shadowRadius = 1
        self.contentView.layer.shadowPath = shadowPath
        self.contentView.layer.masksToBounds = false
        self.contentView.clipsToBounds = false
    }
}

// MARK: - CalendarDetailDelegate

extension CalendarDetailViewController: CalendarDetailDelegate {
    // - Details load has completed
    func detailLoaded(_ detail: CalendarEventDetail) {
        self.title = detail.topic
        self.timeLabel.text = detail.time
        self.dateLabel.text = detail.date
        self.topicLabel.text = detail.topic
        self.bodyTextView.text = detail.body
    }
}

// MARK: - Theme

extension CalendarDetailViewController: Themeable {}
