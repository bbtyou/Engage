//
//  AssetTableViewCell.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class AssetTableViewCell: UITableViewCell {

    // - Outlets
    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleUnderlineView: UIView!
    
    // - The presenter for the view
    weak var homePresenter: HomePresenter?
    
    // - Asset domain data
    var assets: (section: Int, assets: [Asset])? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // - The index for the section
    var sectionIndex: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleUnderlineView.backgroundColor = self.themeColor
        
        // - Add the long press gesture
        let favoriteLongPress = UILongPressGestureRecognizer.init(target: self, action: #selector(toggleFavorite(_:)))
        favoriteLongPress.minimumPressDuration = 1
        favoriteLongPress.delaysTouchesBegan = true
        
        self.collectionView.addGestureRecognizer(favoriteLongPress)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @objc fileprivate func toggleFavorite(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: self.collectionView)

            // - Get the index path for the item
            if let indexPath = self.collectionView.indexPathForItem(at: point), self.sectionIndex > -1 {
                self.homePresenter?.toggleFavorite(indexPath.item, self.sectionIndex)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AssetTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIDevice.current.sizeClass == .compact ? CGSize(width: 104, height: 135) : CGSize(width: 124, height: 155)
    }
}

// MARK: - UICollectionView

extension AssetTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let assets = self.assets {
            return assets.assets.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        
        // - Setup the cell
        if let asset = self.assets?.assets[indexPath.item] {
            cell.assetImageView.fetchImage(Current.base(), asset.imagePath, Current.imageCache(), true)
            asset.isFavorite ? cell.drawBorder() : cell.clearBorder()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.homePresenter?.selectAsset(self.sectionIndex, index: indexPath.item)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - Themeable

extension AssetTableViewCell: Themeable {}
