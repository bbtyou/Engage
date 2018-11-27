//
//  DrawerNavigationController.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

class DrawerNavigationController: UINavigationController {
	
    weak var drawerPresenter: DrawerPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // - Update the navigation bar for each view controller in the navigation stack
        self.viewControllers.forEach { (controller) in
            self.addNavigationButtons(controller)
        }
    }
	
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        viewControllers.forEach { (controller) in
            self.addNavigationButtons(controller)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    fileprivate func addNavigationButtons(_ controller: UIViewController) {

        // - Add the menu items
        let menuItem = UIBarButtonItem.init(image: UIImage.init(named: "hamburger_menu"), style: .plain, target: self, action: #selector(toggleDrawer))
        menuItem.style()
        
        let backItem = UIBarButtonItem.init(image: UIImage.init(named: "back_button"), style: .plain, target: self, action: #selector(back))
        backItem.style()
        
        // - If this is the first view controller on the stack then we don't add the back button
        var buttons = [menuItem]
        if self.viewControllers.first != controller {
            buttons.append(backItem)
        }
        
        controller.navigationItem.leftBarButtonItems = buttons

    }

    // - Drawer menu handler
    @objc fileprivate func toggleDrawer() {
        self.drawerPresenter?.toggleDrawer()
    }
    
    // - Back button handler
    @objc fileprivate func back() {
        self.popViewController(animated: true)
    }
}

// MARK: - UINavigationBarDelegate

extension DrawerNavigationController: UINavigationBarDelegate {
	
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)

        // - Add the navigation buttons when a view controller is pushed
        self.addNavigationButtons(viewController)
	}
}
