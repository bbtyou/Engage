//
//  CalendarDetailPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/24/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import DateToolsSwift

class CalendarDetailPresenter {
    
    // - View for presenter
    weak var delegate: CalendarDetailDelegate?
    
    // - The detail event
    fileprivate let detail: CalendarEvent

    init(_ detail: CalendarEvent) {
        self.detail = detail
    }
    
    func loadDetail() {
        // - Get the date
        let month = Date.monthFromUTCString(self.detail.start)
        let day = Date.dayFromUTCString(self.detail.start)
        let year = Date.yearFromUTCString(self.detail.start)
        let date = "\(month)/\(day)/\(year)"
        
        // - Fill out time, topic and description
        let time = Date.localTimeFromDate(utc: self.detail.start)
        let topic = self.detail.title
        let body = self.detail.description
        
        self.delegate?.detailLoaded((time, date, topic, body))
    }
}
