//
//  DrawerPresenter.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

fileprivate enum DrawerState: Int {
    case open
    case closed
}

class DrawerPresenter {

    // - Drawer presenter delegate (view)
	weak var delegate: DrawerDelegate?
	
    // - Drawer state
    fileprivate var state: DrawerState = .closed
    
    // - Enabled or disabled
    fileprivate var enabled: Bool = true

    // - Drawer contents
    fileprivate var drawerActions = [Category]()
    
    // - Load the actions
    func loadActions() {
        let dataSource = PortalDataSource.init()

        dataSource.fetchCategories({ (categories) in
            // - Filter out all categories that are actions
            self.drawerActions = categories.filter({ (category) -> Bool in
                return category.action.trimmingCharacters(in: .whitespaces).count > 0
            })
            
            // - Sort the actions in based on what we get from the server for order
            self.drawerActions.sort(by: { (firstCat, secondCat) -> Bool in
                return (Int(secondCat.lft) ?? 0) > (Int(firstCat.lft) ?? 0)
            })
            
            // - Insert the built in categories included in the app
            // - Home, Calendar, Inbox
            let home = Category.init(id: "home", title: "Home", icon: CommonImages.home.rawValue, banner: "", lft: "0", level: "", action: "app://home", files: [])
            self.drawerActions.insert(home, at: 0)
            
            let calendar = Category.init(id: "calendar", title: "Calendar", icon: "calendar", banner: "", lft: "0", level: "", action: "app://calendar", files: [])
            self.drawerActions.insert(calendar, at: 1)
            
            let inbox = Category.init(id: "inbox", title: "Inbox", icon: "inbox", banner: "", lft: "0", level: "", action: "app://inbox", files: [])
            self.drawerActions.insert(inbox, at: 2)
            
            // - Map the actions to our domain object tuple and notify the view
            // - that the contents have loaded.
            self.delegate?.contentsLoaded(self.drawerActions.map({ (category) -> DrawerItem in
                return (category.title, category.icon)
            }))
        }) { (error) in
            // - Show empty drawer error
            self.delegate?.showEmptyDrawer(withMessage: error)
        }
        
        self.delegate?.updateFooterView(withImage: "logout", text: "Logout")
    }
    
    func pressFooter() {
        self.delegate?.showSpinner("Logging out...")
        self.delegate?.exitComplete()
    }
    
    func panOpenDrawer() {
        if self.enabled == false || self.state == .open {
            return
        }
        
        self.open()
    }
    
    func panCloseDrawer() {
        if self.state == .closed {
            return
        }
        
        self.close()
    }
    
    func toggleDrawer() {
        if self.enabled == false {
            return
        }
        
        if self.state == .open {
            self.close()
        }
        else {
            self.open()
        }
    }
    
    func enable() {
        self.enabled = true
    }
    
    func disable() {
        if self.state == .open {
            self.close()
        }
        
        self.enabled = false
    }

    func selectAction(_ index: Int) {
        self.close()
        
        let action = self.drawerActions[index]
        self.delegate?.openItem((action.action, action.title))
    }
    
    // MARK: - Private
    
    private func open() {
        self.state = .open
        self.delegate?.open()
    }
    
    private func close() {
        self.state = .closed
        self.delegate?.close()
    }

}
