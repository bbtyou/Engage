//
//  DrawerTableViewCell.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import wvslib

class DrawerTableViewCell: UITableViewCell {
    // MARK: - Outlets
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var badgeView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.iconImageView.image = nil
        self.titleLabel.text = nil
        self.badgeView.isHidden = true
    }
}

// MARK: - Reusable
extension DrawerTableViewCell: ReusableView {}
