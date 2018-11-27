//
//  DrawerViewController.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

// Type for drawer contents
typealias DrawerItem = (title: String, iconPath: String)

// - View Controller which defines the main menu drawer
// - which can slide out from the left side of the screen
class DrawerViewController: UIViewController, Containerable {

	// MARK: - Outlets
	
    @IBOutlet fileprivate var drawerContainer: UIView!
	@IBOutlet fileprivate var drawerTableView: UITableView!
    @IBOutlet fileprivate var leadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var footerButton: UIButton!
    
	// - MARK - Containerable
	
	var container: UIView?
	var detailView: UIViewController?
	
	// - Presenter
	var presenter: DrawerPresenter? {
		didSet {
			self.presenter?.delegate = self
		}
	}
	
	// - Navigation controller for detail views
	fileprivate var detailNavController = UINavigationController.init()
	
    // - The contents for the drawer
    fileprivate var drawerItems = [DrawerItem]()
    
    // - Empty drawer message
    fileprivate var emptyDrawerMsg: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		// - Create container view
        self.close()
        self.createContainer()
        
        // - Populate the drawer
        self.presenter?.loadActions()
	}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let layer = self.footerButton.superview?.layer {
            layer.masksToBounds = false
            layer.shadowOffset = CGSize.zero
            layer.shadowColor = UIColor.init(white: 0.0, alpha: 0.5).cgColor
            layer.shadowOpacity = 1.0
            layer.shadowRadius = 1.0
            layer.shadowPath = UIBezierPath.init(rect: layer.bounds).cgPath
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.drawerTableView.reloadData()
        }) { (context) in

        }
    }
    
    // MARK: - Actions
    
    @IBAction func panToOpen(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.presenter?.panOpenDrawer()
    }
    
    @IBAction func swipeToClose(_ sender: UISwipeGestureRecognizer) {
        self.presenter?.panCloseDrawer()
    }
    
    @IBAction func footerButtonTapped(_ sender: UIButton) {
        self.presenter?.pressFooter()
    }
    
	// MARK: - Private

    @objc fileprivate func touchOverlayTapped(_ sender: UITapGestureRecognizer) {
        self.presenter?.toggleDrawer()
    }
    
	fileprivate func showDrawerShadow() {
        let layer = self.drawerContainer.layer
        layer.masksToBounds = false
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.init(white: 0.0, alpha: 0.8).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 4.0
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
	}
	
	fileprivate func hideDrawerShadow() {
        let layer = self.drawerContainer.layer
        layer.masksToBounds = true
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 0.0
	}
    
    fileprivate func createTouchOverlay() {
        let touchOverlay = UIView.init(frame: .zero)
        touchOverlay.translatesAutoresizingMaskIntoConstraints = false
        touchOverlay.backgroundColor = UIColor.black
        touchOverlay.alpha = 0.5
        touchOverlay.tag = 555
        
        // - Add tap gesture to the overlay
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(touchOverlayTapped(_:)))
        tap.numberOfTapsRequired = 1
        touchOverlay.addGestureRecognizer(tap)
        
        // - Add the touch overlay to the container
        self.view.addSubview(touchOverlay)
        
        touchOverlay.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        touchOverlay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        touchOverlay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        touchOverlay.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
	// - Creates the container view to satisfy the Containerable conformance
	private func createContainer() {
		let containerView = UIView.init(frame: .zero)
		containerView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(containerView)
		
		containerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		
		self.container = containerView
		
		// - Create the navigation controller and add it to the view
		let storyboard = UIStoryboard.init(name: "DrawerNavigation", bundle: nil)
		if let navController = storyboard.instantiateInitialViewController() as? DrawerNavigationController {
            // - Set the presenter for the drawer
            navController.drawerPresenter = self.presenter
            
            // - Add the drawer navigation to the drawer view controller
			self.addDetailView(navController)
            self.detailNavController = navController
		}
	}
}

// MARK: - DrawerDelegate

extension DrawerViewController: DrawerDelegate {
    
    func open() {
        self.showDrawerShadow()
        self.createTouchOverlay()
        self.view.layoutIfNeeded()
        
        self.view.bringSubviewToFront(self.drawerContainer)
        self.leadingConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        self.drawerTableView.animateScrollViewBound(.vertical)
    }
    
    func close() {
        self.leadingConstraint.constant = -(self.drawerContainer.bounds.size.width)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.view.layoutSubviews()
        
        }) { (finished) in
        
            if finished {
                self.view.viewWithTag(555)?.removeFromSuperview()
                self.hideDrawerShadow()
            }
            
        }
    }
	
    func contentsLoaded(_ contents: [DrawerItem]) {
        self.drawerItems = contents
        self.drawerTableView.isScrollEnabled = true
        self.drawerTableView.reloadData()
        
        if contents.count > 0 {
            self.presenter?.selectAction(0)
            self.drawerTableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    func showEmptyDrawer(withMessage additionalMsg: String?) {
        self.drawerItems = []
        self.emptyDrawerMsg = additionalMsg
        self.drawerTableView.isScrollEnabled = false
        self.drawerTableView.reloadData()
    }
    
    func openItem(_ item: (action: String, title: String)) {
        let handler = AppConfigurator.shared.actionHandler
        
        if let viewController = handler.handleAction(item.action, item.title) {
            self.detailNavController.setViewControllers([viewController], animated: false)
        }
    }
    
    func exitComplete() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func updateFooterView(withImage name: String, text: String) {
        let image = UIImage.init(named: name)
        
        if let themeColor = AppConfigurator.shared.themeConfigurator?.themeColor {
            self.footerButton.setImage(image?.maskedImage(with: themeColor).resize(toWidth: 39.0)?.resize(toHeight: 39.0), for: .normal)
        }
        
        self.footerButton.setTitle(text, for: .normal)
        self.footerButton.setBackgroundImage(UIImage.imageFromColor(color: UIColor.gray.withAlphaComponent(0.5)), for: .highlighted)
        self.footerButton.setBackgroundImage(UIImage.imageFromColor(color: UIColor.white), for: .normal)
    }
}

// MARK: - UITableViewDelegate, UITableViewDatasource

extension DrawerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.drawerItems.count > 0 {
            return self.drawerItems.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter?.selectAction(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // - Display the empty contents cell
        if self.drawerItems.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DrawerEmptyTableViewCell", for: indexPath) as! DrawerTableViewCell
            
            var iconImage = CommonImages.infosignal.image
            if let themeColor = AppConfigurator.shared.themeConfigurator?.themeColor {
                iconImage = iconImage?.maskedImage(with: themeColor)
            }
            
            cell.iconImageView.image = iconImage
            cell.titleLabel.text = "There are no menu items to display.\n" + "\(self.emptyDrawerMsg ?? "")"
            
            return cell
        }
        
        // - Drawer contents
        let drawerItem = self.drawerItems[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "DrawerTableViewCell", for: indexPath) as! DrawerTableViewCell
        cell.titleLabel.text = drawerItem.title
        cell.iconImageView.fetchImage(drawerItem.iconPath, false, CommonImages.webpage.image, CGSize.init(width: 39.0, height: 39.0), AppConfigurator.shared.themeConfigurator?.themeColor)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.drawerItems.count > 0 ? (UIDevice.current.sizeClass == .compact ? 60 : 80) : tableView.bounds.size.height
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}
