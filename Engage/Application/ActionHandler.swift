//
//  ActionHandler.swift
//  Engage
//
//  Created by Charles Imperato on 11/14/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

// - Application actions
enum AppActions: String {
    
    case proforma = "app://proforma"
    case techsupport = "app://showtechsupportcontact"
    case repsupport = "app://showsupportcontact"
    case home = "app://home"
    case calendar = "app://calendar"
    case inbox = "app://inbox"
    case logout = "app://logout"
    
}

protocol ActionHandler {
    // - Based on the action it returns a view controller
    func handleAction(_ action: String, _ title: String?) -> UIViewController?
}

// - Handles engage actions
class AppActionHandler: ActionHandler {
    
    func handleAction(_ action: String, _ title: String?) -> UIViewController? {
        var viewController = UIViewController.init()

        // - Convert the action to lowercase
        let lowAction = action.lowercased()
        
        // - Check for a web action
        if (lowAction.starts(with: "http://") || lowAction.starts(with: "https://")) || (!lowAction.starts(with: "app://")) {
            if let webView = UIStoryboard.init(name: "Web", bundle: nil).instantiateInitialViewController() as? WebViewController {
                webView.presenter = WebViewPresenter.init(withPath: action, title)
                viewController = webView
            }
        }
        else {
            switch lowAction {
                case AppActions.home.rawValue:
                    if let homeView = UIStoryboard.init(name: "Home", bundle: nil).instantiateInitialViewController() as? HomeViewController {
                        homeView.presenter = HomePresenter.init()
                        viewController = homeView
                    }
                
                case AppActions.inbox.rawValue:
                    if let inboxView = UIStoryboard.init(name: "Inbox", bundle: nil).instantiateInitialViewController() as? InboxViewController {
                        inboxView.presenter = InboxPresenter.init()
                        viewController = inboxView
                    }
                
                case AppActions.calendar.rawValue:
                    if let calendarView = UIStoryboard.init(name: "Calendar", bundle: nil).instantiateInitialViewController() as? CalendarViewController {
                        calendarView.presenter = CalendarPresenter.init()
                        viewController = calendarView
                    }
                
                case AppActions.logout.rawValue:
                    return nil
                
                case AppActions.repsupport.rawValue:
                    if let supportView = UIStoryboard.init(name: "Support", bundle: nil).instantiateInitialViewController() as? SupportViewController {
                        supportView.presenter = RepSupportPresenter.init()
                        viewController = supportView
                    }
                
                case AppActions.techsupport.rawValue:
                    if let supportView = UIStoryboard.init(name: "Support", bundle: nil).instantiateInitialViewController() as? SupportViewController {
                        viewController = supportView
                    }
                
                default:
                    break
            }
        }
        
        return viewController
    }
}
