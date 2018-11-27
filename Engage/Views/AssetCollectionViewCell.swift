//
//  AssetCollectionViewCell.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    
    // - Outlets
    @IBOutlet var assetImageView: UIImageView!
    @IBOutlet var noImageLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.noImageLabel.textColor = UIColor.darkGray

        // - Add default border
        self.layer.borderColor = AppConfigurator.shared.themeConfigurator?.themeColor.cgColor ?? UIColor.black.cgColor
        self.layer.borderWidth = 0.5
    }
    
    func drawBorder() {
        self.layer.borderColor = AppConfigurator.shared.themeConfigurator?.themeColor.cgColor ?? UIColor.black.cgColor
        self.layer.borderWidth = 3.0
    }
    
    func clearBorder() {
        self.layer.borderWidth = 0.5
    }
    
    // MARK: - Private
}
