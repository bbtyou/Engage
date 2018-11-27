//
//  CalendarPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/24/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class CalendarPresenter {
    
    // - View for the calendar
    weak var delegate: CalendarDelegate?
    
    // - The calendar events
    fileprivate var events = [CalendarEvent]()
    
    // - Loads the calendar data
    func loadCalendar() {
        let dataSource = CalendarDataSource.init()
        
        self.delegate?.showSpinner("Loading calendar data...")
        dataSource.fetchEvents { (events, error) in
            self.delegate?.hideSpinner()
            
            self.events = events
            
            if let error = error {
                log.error("The calendar data could not be retrieved. \(error).")
                // TODO: Show calendar error
                return
            }
            
            if self.events.count == 0 {
                // TODO: Show empty
                return
            }
            
            self.delegate?.eventsLoaded(self.events.map({ (calEvent) -> CalendarDayEvent in
                return (Date.dateFromUTCString(utc: calEvent.start) ?? Date(),
                            Date.dateFromUTCString(utc: calEvent.end) ?? Date(),
                                false,
                                    calEvent.title,
                                        calEvent.description)
            }))
        }
    }
    
    // - AN event was selected
    func selectEvent(_ index: Int) {
        guard index < self.events.count, index >= 0 else {
            log.warning("The calendar event could not be selected because the index value is not within range of the current calendar item structure.")
            return
        }
        
        self.delegate?.didSelectEvent(CalendarDetailPresenter.init(self.events[index]))
    }
}
