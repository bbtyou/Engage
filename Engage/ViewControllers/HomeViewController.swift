//
//  HomeViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class HomeViewController: EngageViewController {

    // - Outlets
    @IBOutlet fileprivate var assetTableView: UITableView!
    @IBOutlet fileprivate var marqueeView: UIView!
    @IBOutlet fileprivate var emptyFavoritesView: UIView!
    @IBOutlet fileprivate var emptyFavoritesLabel: UILabel!
    @IBOutlet fileprivate var emptyFavoritesInstructionLabel: UILabel!
    @IBOutlet fileprivate var emptyFavoritesImageView: UIImageView!
    @IBOutlet fileprivate var dailyUpdateView: UIView!
    @IBOutlet fileprivate var dailyUpdateTextView: UITextView!
    
    // - Presenter for view
    var presenter: HomePresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    // - The assets
    fileprivate var assets = [[Asset]]() {
        didSet {
            self.assetTableView.reloadData()
        }
    }
    
    // - The section names
    fileprivate var sections = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home"
        
        // - Set up the favorites button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: CommonImages.favoritesdisabled.image, style: .plain, target: self, action: #selector(favoritesTapped))
        self.navigationItem.rightBarButtonItem?.tintColor = AppConfigurator.shared.themeConfigurator?.themeColor
        
        // - Style the empty favorites view
        self.emptyFavoritesLabel.textColor = AppConfigurator.shared.themeConfigurator?.headerTextColor
        self.emptyFavoritesInstructionLabel.textColor = AppConfigurator.shared.themeConfigurator?.bodyTextColor
        self.emptyFavoritesImageView.image = CommonImages.longpress.image?.maskedImage(with: UIColor.lightGray)
        
        // - Load the daily updates
        self.presenter?.fetchDailyUpdates()

        // - Load the assets
        self.presenter?.fetchAssets()
    }
    
    deinit {
        log.verbose("** Deallocated viewController \(HomeViewController.self).")
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
    }
    
    func marqueeUpdated(_ text: String) {
        UIView.animate(withDuration: 0.35, animations: {
            self.dailyUpdateTextView.alpha = 0
        }) { (finished) in
            if finished {
                self.dailyUpdateTextView.text = text
                
                UIView.animate(withDuration: 0.35, animations: {
                    self.dailyUpdateTextView.alpha = 1.0
                })
            }
        }
    }
    
    func favoritesEnabled() {
        self.navigationItem.rightBarButtonItem?.image = CommonImages.favoritesenabled.image
        if self.assets.count > 0 {
            self.assetTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func favoritesDisabled() {
        self.navigationItem.rightBarButtonItem?.image = CommonImages.favoritesdisabled.image
        self.hideEmptyFavorites()
        
        if self.assets.count > 0 {
            self.assetTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
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
        self.notify(message: message, 2.0)
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
