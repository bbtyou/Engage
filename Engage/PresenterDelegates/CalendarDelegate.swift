//
//  CalendarDelegate.swift
//  Engage
//
//  Created by Charles Imperato on 11/24/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

protocol CalendarDelegate: class {
    
    // - Notifies the view that the calendar has been loaded
    func eventsLoaded(_ events: [CalendarDayEvent])
    
    // - Notifies the view that a selected event has occurred and the presenter is passed along
    func didSelectEvent(_ presenter: CalendarDetailPresenter)
    
}
