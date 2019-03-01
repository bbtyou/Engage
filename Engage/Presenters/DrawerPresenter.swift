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
    
    init() {
        // - Listen for reload events
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrawer), name: Notification.Name("updateDrawer"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateDrawer"), object: nil)
    }
    
    // - Load the actions
    func loadActions(_ useCache: Bool = false, _ open: Bool = true) {
        Current.main().portal(useCache) { result in
            switch result {
            case .success(let portal):
                if portal.categories.count == 0 {
                    self.delegate?.showEmptyDrawer(withMessage: nil)
                    return
                }
                
                // Message unread count
                let unread = portal.messages.count - portal.messages.filter({ $0.read.count > 0 }).count
                
                // Filter actions and sort
                self.drawerActions = portal.categories.filter({ $0.action.count > 0 }).sorted(by: { $0.lft < $1.lft })
                
                // - Insert the built in categories included in the app
                // - Home, Calendar, Inbox
                let home = Category.init(id: "home", title: "Home", icon: Images.home.rawValue, banner: "", lft: "0", level: "", action: "app://home", files: [])
                self.drawerActions.insert(home, at: 0)
                
                let calendar = Category.init(id: "calendar", title: "Calendar", icon: Images.calendar.rawValue, banner: "", lft: "0", level: "", action: "app://calendar", files: [])
                self.drawerActions.insert(calendar, at: 1)
                
                let inbox = Category.init(id: "inbox", title: "Inbox", icon: Images.inbox.rawValue, banner: "", lft: "0", level: "", action: "app://inbox", files: [])
                self.drawerActions.insert(inbox, at: 2)
                
                // - Map the actions to our domain object tuple and notify the view
                // - that the contents have loaded.
                
                self.delegate?.contentsLoaded(self.drawerActions.map({ ($0.title, $0.icon, unread > 0 && $0.id == "inbox" ? "\(unread)" : nil) }))
                
                if open {
                    self.delegate?.selectAction(0)
                }
                
            case .failure(let error):
                Current.log().error(error)
                self.delegate?.showEmptyDrawer(withMessage: error.localizedDescription)
            }
        }

        self.delegate?.updateFooterView(withImage: "logout", text: "Logout")
    }
    
    func pressFooter() {
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
    @objc fileprivate func updateDrawer() {
        self.loadActions(false, false)
    }
    
    private func open() {
        self.state = .open
        self.delegate?.open()
    }
    
    private func close() {
        self.state = .closed
        self.delegate?.close()
    }

}
