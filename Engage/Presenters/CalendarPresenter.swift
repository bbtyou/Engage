//
//  CalendarPresenter.swift
//  Engage
//
//  Created by Charles Imperato on 11/24/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

struct CalendarDayEvent {
    let start: Date
    let end: Date
    let isAllDay: Bool
    let title: String
    let description: String
}

class CalendarPresenter {
    
    // - View for the calendar
    weak var delegate: CalendarDelegate?
    
    // - The calendar events
    fileprivate var events = [CalendarEvent]()
    
    // - Loads the calendar data
    func loadCalendar() {

        (self.delegate as? Waitable)?.showSpinner("Loading calendar...")
        
        Current.calendar().cal { result in
            (self.delegate as? Waitable)?.hideSpinner()
            
            switch result {
            case .success(let events):
                self.events = events
                self.delegate?.eventsLoaded(
                    self.events.map({
                        CalendarDayEvent.init(start: Date.dateFromUTCString(utc: $0.start) ?? Date(), end: Date.dateFromUTCString(utc: $0.end) ?? Date(), isAllDay: false, title: $0.title, description: $0.description)
                    }))

            case .failure(let error):
                // TODO: Show error
                Current.log().error(error)
            }
        }
    }
    
    // - AN event was selected
    func selectEvent(_ index: Int) {
        guard self.events.indices.contains(index) else {
            Current.log().warning("The calendar event could not be selected because the index value is not within range of the current calendar item structure.")
            return
        }

        self.delegate?.didSelectEvent(CalendarDetailPresenter.init(self.events[index]))
    }
}
