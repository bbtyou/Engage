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
        let dataSource = PortalDataSource.init()
        
        if showSpinner {
            self.delegate?.showSpinner("Loading inbox...")
        }
        
        // - Clear the existing messages
        self.messages.removeAll()
        
        dataSource.fetchMessages({ (messages) in
            self.delegate?.hideSpinner()
            
            self.messages = messages

            if self.messages.count == 0 {
                self.delegate?.showEmpty()
                return
            }
            
            self.delegate?.messagesLoaded(self.messages.map({ (message) -> InboxMessage in
                return (Date.dateFromUTCString(utc: message.time) ?? Date(), message.subject, message.body, message.author, message.read.count > 0)
            }))
        }) { (error) in
            self.delegate?.hideSpinner()
            
            log.error(error)
            self.delegate?.showError(withMessage: error)
            self.delegate?.showEmpty()
        }
    }
    
    func messageSelected(_ index: Int) {
        let message = self.messages[index]
        let presenter = InboxDetailPresenter.init(withDetails: InboxDetail(self.formatTime(Date.dateFromUTCString(utc: message.time) ?? Date()), message.subject, message.author, message.body))
        
        // - Notify the view with the presenter
        self.delegate?.showDetails(presenter)
    }
    
    func markRead(_ index: Int) {
        let message = self.messages[index]

        // - Message is already marked as read
        if message.read.count > 0 {
            return
        }
        
        // - Send a request to mark the message as read
        let request = MarkMessageReadRequest.init(messageId: message.id)
        request.sendRequest { (response, data, error) in
            if let error = self.checkResponse(response, data, error) {
                log.error("Unable to mark message \(message.id) as read. \(error)")
                return
            }
            
            let newMessage = Message.init(id: message.id, time: message.time, subject: message.subject, body: message.body, author: message.author, read: "now")
            self.messages.remove(at: index)
            self.messages.insert(newMessage, at: index)
            
            // - Load
            self.delegate?.messagesLoaded(self.messages.map({ (message) -> InboxMessage in
                return (Date.dateFromUTCString(utc: message.time) ?? Date(), message.subject, message.body, message.author, message.read.count > 0)
            }))

        }
    }
    
    func delete(_ index: Int) {
        let message = self.messages[index]
        
        let request = DeleteMessageRequest.init(messageId: message.id)
        request.sendRequest { (response, data, error) in
            if let error = self.checkResponse(response, data, error) {
                log.error("Unable to delete \(message.id). \(error)")
                self.delegate?.showError(withMessage: error.localizedDescription)
                return
            }
            
            self.messages.remove(at: index)
            
            // - Notify the view
            if self.messages.count == 0 {
                self.delegate?.showEmpty()
            }
            else {
                self.delegate?.messagesLoaded(self.messages.map({ (message) -> InboxMessage in
                    return (Date.dateFromUTCString(utc: message.time) ?? Date(), message.subject, message.body, message.author, message.read.count > 0)
                }))
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

