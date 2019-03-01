//
//  HomeViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit
import wvslib

class HomeViewController: UIViewController {

    // - Outlets
    @IBOutlet fileprivate var assetTableView: UITableView!
    @IBOutlet fileprivate var marqueeView: UIView!
    @IBOutlet fileprivate var emptyView: UIView!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    @IBOutlet fileprivate var emptyImageView: UIImageView!
    @IBOutlet fileprivate var emptyFavoritesView: UIView!
    @IBOutlet fileprivate var emptyFavoritesLabel: UILabel!
    @IBOutlet fileprivate var emptyFavoritesInstructionLabel: UILabel!
    @IBOutlet fileprivate var emptyFavoritesImageView: UIImageView!
    
    // - Presenter for view
    var presenter: HomePresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    // - Favorites turned on
    fileprivate var favoritesOn = false
    
    // - The assets
    fileprivate var assets = [[Asset]]() {
        didSet {
            let contentOffset = self.favoritesOn ? CGPoint.zero : self.assetTableView.contentOffset
            self.assetTableView.reloadData()
            self.assetTableView.layoutIfNeeded()
            self.assetTableView.setContentOffset(contentOffset, animated: false)
        }
    }
    
    // - The section names
    fileprivate var sections = [String]()
    
    // - Notifiable
    var notifyContainer: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home"
        
        // - Set up the favorites button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: Images.favoritesdisabled.image, style: .plain, target: self, action: #selector(favoritesTapped))
        self.navigationItem.rightBarButtonItem?.tintColor = self.themeColor
        
        // - Style the empty favorites view
        self.emptyFavoritesLabel.textColor = self.headerTextColor
        self.emptyFavoritesInstructionLabel.textColor = self.bodyTextColor
        self.emptyFavoritesImageView.image = Images.longpress.image?.maskedImage(with: UIColor.lightGray)
        
        self.emptyLabel.textColor = self.headerTextColor
        self.emptyImageView.image = CommonImages.emptyimage.image?.maskedImage(with: UIColor.lightGray)
        self.hideEmptyFavorites()
        
        // - Load the assets
        self.presenter?.fetchAssets()
    }
    
    deinit {
        Current.log().verbose("** Deallocated viewController \(HomeViewController.self).")
    }

    // MARK: - Actions
    
    @objc fileprivate func favoritesTapped() {
        self.presenter?.toggleFavorites()
    }
}

// MARK: - HomeDelegate

extension HomeViewController: HomeDelegate {
    func fileOpened(_ presenter: WebViewPresenter) {
        if let webViewController = UIStoryboard.init(name: "Web", bundle: nil).instantiateInitialViewController() as? WebViewController {
            webViewController.presenter = presenter
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    func assetsLoaded(_ assets: [[Asset]], _ sections: [String]) {
        self.sections = sections
        self.assets = assets
    }
    
    func showEmpty(_ message: String?) {
        self.assets = []
        self.sections = []
        
        self.emptyView.isHidden = false
        self.view.bringSubviewToFront(self.emptyView)
    }
    
    func hideEmpty() {
        self.emptyView.isHidden = true
        self.view.sendSubviewToBack(self.emptyView)
    }
    
    func marqueeUpdated(_ text: String) {
    }
    
    func favoritesEnabled() {
        self.navigationItem.rightBarButtonItem?.image = Images.favoritesenabled.image
        self.favoritesOn = true
    }
    
    func favoritesDisabled() {
        self.navigationItem.rightBarButtonItem?.image = Images.favoritesdisabled.image
        self.hideEmptyFavorites()
        self.favoritesOn = false
    }
    
    func showEmptyFavorites() {
        self.emptyFavoritesView.isHidden = false
        self.view.bringSubviewToFront(self.emptyFavoritesView)
    }
    
    func hideEmptyFavorites() {
        self.emptyFavoritesView.isHidden = true
        self.view.sendSubviewToBack(self.emptyFavoritesView)
    }
    
    func showBanner(_ message: String) {
        self.notify(message: message, 1.5)
    }
}

// - MARK: - UITableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetTableViewCell", for: indexPath) as! AssetTableViewCell

        cell.titleLabel.text = self.sections[indexPath.row]
        cell.homePresenter = self.presenter
        cell.sectionIndex = indexPath.row
        cell.assets = (indexPath.row, self.assets[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.sizeClass == .compact ? 230.0 : 250.0
    }
}

// MARK: - Waitable

extension HomeViewController: Waitable {}

// MARK: - Themeable

extension HomeViewController: Themeable {}

// MARK: - Notifiable

extension HomeViewController: Notifiable {}
