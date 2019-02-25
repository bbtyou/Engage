//
//  InboxDetailPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/22/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

// - Tuple that represents info for a detail
typealias InboxDetail = (date: String, subject: String, author: String, body: String)

class InboxDetailPresenter {
    
    // - View delegate
    weak var delegate: InboxDetailDelegate?
    
    // - The inbox message details
    fileprivate var details: InboxDetail?
    
    init(withDetails details: InboxDetail) {
        self.details = details
    }
    
    func load() {
        guard let details = self.details else {
            Current.log().warning("The message details could not be loaded.")
            // - Show error
            return
        }
        
        self.delegate?.detailsLoadComplete(details)
    }
}
