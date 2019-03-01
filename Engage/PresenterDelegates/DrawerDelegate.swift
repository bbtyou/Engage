//
//  DrawerDelegate.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol DrawerDelegate: class {
	
    // - Opens the drawer if it is closed
    func open()
    
    // - Closes the drawer if it is open
    func close()
    
    // - Loaded the contents
    func contentsLoaded(_ contents: [DrawerItem])
    
    // - Selects the given item in the drawer
    func selectAction(_ index: Int)
    
    // - Shows empty drawer contents with an optional additional message
    func showEmptyDrawer(withMessage additionalMsg: String?)
 
    // - Opens the proper action
    func openItem(_ item: (action: String, title: String))
    
    // - Notifies the view that the exit is complete
    func exitComplete()
    
    // - Updates the footer view button with an image name and title
    func updateFooterView(withImage name: String, text: String)
    
}
