//
//  Portal.swift
//  Engage
//
//  Created by Charles Imperato on 11/6/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// MARK - User object
struct User: Codable {
    
    let name: String
    let login: String
    let city: String
    let state: String
    let phone: String
    let photo: String
    
}

// MARK: - Contact object
struct Contact: Codable {
    
    enum CodingKeys: String, CodingKey {
        case techSupport = "tech_support"
        case phone = "phone"
        case text = "text"
        case email = "email"
    }
    
    let phone: String
    let text: String
    let email: String
    let techSupport: String
    
}

// MARK: - Favorite object
struct Favorite: Codable {
    
    let id: String
    let title: String
    let thumbnail: String
    let url: String
    
}

// MARK: - Message object
struct Message: Codable {
    
    let id: String
    let time: String
    let subject: String
    let body: String
    let author: String
    let read: String
    
}

// MARK: - File object
struct File: Codable {
    
    let id: String
    let title: String
    let description: String
    let mimetype: String
    let url: String
    var thumbnail: String?
    
}

// MARK: - Category object
struct Category: Codable {
    
    let id: String
    let title: String
    let icon: String
    let banner: String
    let lft: String
    let level: String
    let action: String
    let files: [File]

}

// Mark: - Proforma
struct Proforma: Codable {

    struct Params: Codable {
        
        let wellness: String
        let advanced: String
        let mental: String
        let behavioral: String
        
    }
    
    let params: Params
    let formula: String
}

// MARK: - Marquee
struct Marquee: Codable {
    
    let text: [String]
    let delay: String
    
}

// MARK: Portal
struct Portal: Codable {
    // Contact info
    let contact: Contact
    
    // Favorited assets
    let favorites: [Favorite]
    
    // Inbox messages
    let messages: [Message]
    
    // Menu and asset categories
    let categories: [Category]
}

// MARK: - Success/Failure

struct PostResult: Codable {
    // Successful completion of task
    var ok: Int?

    // Failure with a string
    var failure: String?
}
