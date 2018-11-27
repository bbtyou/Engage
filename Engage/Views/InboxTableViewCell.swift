//
//  InboxTableViewCell.swift
//  Engage
//
//  Created by Charles Imperato on 11/21/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet fileprivate var fromLabel: UILabel!
    @IBOutlet fileprivate var topicLabel: UILabel!
    @IBOutlet fileprivate var bodyLabel: UILabel!
    @IBOutlet fileprivate var dateLabel: UILabel!
    @IBOutlet fileprivate var containerView: UIView!
    
    var message: InboxMessage? {
        didSet {
            self.dateLabel.text = self.message?.time.relativeTime
            self.bodyLabel.text = self.message?.body
            self.fromLabel.text = self.message?.author
            self.topicLabel.text = self.message?.subject
            
            // - Change the font if the message is read or not
            let fontName = self.message?.read == true ? "Helvetica" : "Helvetica-Bold"
            self.dateLabel.font = UIFont.init(name: fontName, size: UIDevice.current.sizeClass == .compact ? 15.0 : 17.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        
        // Text colors
        guard let theme = AppConfigurator.shared.themeConfigurator else {
            log.warning("Unable to style inbox cell since no theme was configured.")
            return
        }
        
        // - Style the inbox cell ui
        self.dateLabel.textColor = theme.themeColor
        self.fromLabel.textColor = theme.headerTextColor
        self.topicLabel.textColor = theme.headerTextColor
        self.bodyLabel.textColor = theme.bodyTextColor
        
        // - Set the background
        self.contentView.backgroundColor = theme.backgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
