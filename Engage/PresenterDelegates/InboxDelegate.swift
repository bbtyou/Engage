//
//  InboxDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/21/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol InboxDelegate: class {
    
    // - Notifies the view that the messages have been loaded
    func messagesLoaded(_ messages: [InboxMessage])
    
    // - Shows empty data
    func showEmpty()
    
    // - Shows an error with an optional additional message
    func showError(withMessage message: String?)
    
    // - Shows the message details
    func showDetails(_ presenter: InboxDetailPresenter)

}
