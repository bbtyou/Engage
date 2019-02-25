//
//  InboxPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/21/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

class InboxPresenter {
    
    weak var delegate: InboxDelegate?
    
    // - The loaded messages
    fileprivate var messages = [Message]()
    
    // - Loads the messages from the server
    func load(_ showSpinner: Bool = true) {
        if showSpinner {
            (self.delegate as? Waitable)?.showSpinner("Loading collateral...")
        }
        
        // - Clear the existing messages
        self.messages.removeAll()

        Current.main().portal(false) { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let portal):
                self.messages = portal.messages
                
                if self.messages.count == 0 {
                    self.delegate?.showEmpty()
                    return
                }
                
                self.delegate?.messagesLoaded(self.messages.map({ (Date.dateFromUTCString(utc: $0.time) ?? Date(), $0.subject, $0.body, $0.author, $0.read.count > 0) }))
                
            case .failure(let error):
                Current.log().error(error)
                self.delegate?.showError(withMessage: error.localizedDescription)
                self.delegate?.showEmpty()
            }
        }
    }
    
    func messageSelected(_ index: Int) {
        let message = self.messages[index]
        let presenter = InboxDetailPresenter.init(withDetails: InboxDetail(self.formatTime(Date.dateFromUTCString(utc: message.time) ?? Date()), message.subject, message.author, message.body))
        
        // - Notify the view with the presenter
        self.delegate?.showDetails(presenter)
    }
    
    func markRead(_ index: Int) {
        guard self.messages.indices.contains(index) else {
            Current.log().warning("The message could not be marked read because the index for the message was not valid.")
            return
        }
        
        let message = self.messages[index]
        if message.read.count > 0 { return }
        
        // - Send a request to mark the message as read
        Current.messageAction().markRead(message.id) { result in
            switch result {
            case .success(_):
                self.messages.remove(at: index)
                self.messages.insert(Message.init(id: message.id, time: message.time, subject: message.subject, body: message.body, author: message.author, read: "now"), at: index)
                self.delegate?.messagesLoaded(self.messages.map({ (Date.dateFromUTCString(utc: $0.time) ?? Date(), $0.subject, $0.body, $0.author, $0.read.count > 0) }))

            case .failure(let error):
                Current.log().warning(error)
            }
        }
    }
    
    func delete(_ index: Int) {
        guard self.messages.indices.contains(index) else {
            Current.log().warning("The message could not be deleted because the index for the message was not valid.")
            return
        }
        
        Current.messageAction().delete(self.messages[index].id) { result in
            switch result {
            case .success(_):
                self.messages.remove(at: index)
                if self.messages.count == 0 {
                    self.delegate?.showEmpty()
                }
                else {
                    self.delegate?.messagesLoaded(self.messages.map({ (Date.dateFromUTCString(utc: $0.time) ?? Date(), $0.subject, $0.body, $0.author, $0.read.count > 0) }))
                }
                
            case .failure(let error):
                Current.log().warning(error)
            }
        }
    }
}

// - Private

fileprivate extension InboxPresenter {
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
        
        return formatter.string(from: date)
    }
}

