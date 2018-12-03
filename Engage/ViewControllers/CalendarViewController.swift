//
//  CalendarViewController.swift
//  Engage
//
//  Created by Charles Imperato on 11/24/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import CalendarKit

class CalendarViewController: DayViewController, Notifiable {

    // - Notifiable
    var notifyContainer: UIView?
    
    // - Events for the date
    fileprivate var events = [Event]() {
        didSet {
            self.reloadData()
        }
    }
    
    // - Presenter for the view
    var presenter: CalendarPresenter? {
        didSet {
            self.presenter?.delegate = self
        }
    }
    
    // - Detail presenter
    fileprivate var detailPresenter: CalendarDetailPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Calendar"

        // - Get the theme color if the theme is available.  Otherwise we default to purple
        let themeColor = AppConfigurator.shared.themeConfigurator?.themeColor ?? UIColor.purple
        
        // - Add and style the refresh button
        let refreshButton = UIBarButtonItem.init(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
        refreshButton.image = CommonImages.refresh.image
        refreshButton.tintColor = themeColor
        
        self.navigationItem.rightBarButtonItem = refreshButton
        
        // - Style the calendar
        let style = CalendarStyle.init()
        
        style.header.backgroundColor = themeColor
        style.timeline.lineColor = themeColor
        style.timeline.timeColor = themeColor
        
        style.header.daySelector.inactiveTextColor = UIColor.white
        style.header.daySelector.weekendTextColor = UIColor.white
        style.header.swipeLabel.textColor = UIColor.white
        style.header.daySymbols.weekDayColor = UIColor.white
        style.header.daySymbols.weekendColor = UIColor.white
        
        if let font = UIFont.init(name: "Helvetica", size: 14.0) {
            style.timeline.font = font
        }
        
        // - Commit the style
        self.dayView.updateStyle(style)
        self.dayView.autoScrollToFirstEvent = true
    
        // Do any additional setup after loading the view.
        self.presenter?.loadCalendar()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventdetail", let view = segue.destination as? CalendarDetailViewController {
            view.presenter = self.detailPresenter
        }
    }

    // MARK: - CalendarKit
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let event = eventView.descriptor as? Event, let index = event.userInfo as? Int else {
            return
        }
    
        self.presenter?.selectEvent(index)
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        return events
    }
    
    // MARK: - Private
    
    @objc private func refresh() {
        self.presenter?.loadCalendar()
    }
}

// MARK: - CalendarDelegate

extension CalendarViewController: CalendarDelegate {
    
    func eventsLoaded(_ events: [CalendarDayEvent]) {
        var index = 0
        
        // - Map the events to an EventDescriptor
        let calEvents = events.map { (start, end, isAllDay, title, description) -> Event in
            let event = Event()
            
            event.startDate = start
            event.endDate = end
            event.isAllDay = isAllDay
            
            let titleAttr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.init(name: "Helvetica-Bold", size: 12.0) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.darkText
            ]
            
            let bodyAttr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.init(name: "Helvetica", size: 12.0) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.darkText
            ]
            
            let attributedText = NSMutableAttributedString.init(string: "\(title)\n", attributes: titleAttr)
            attributedText.append(NSAttributedString.init(string: "\(description)", attributes: bodyAttr))
            event.attributedText = attributedText
            
            // - Update the event color
            let eventColor = (AppConfigurator.shared.themeConfigurator?.themeColor ?? UIColor.magenta).withAlphaComponent(0.25)
            event.backgroundColor = eventColor
            event.userInfo = index

            index += 1
            
            return event
        }
        
        self.events = calEvents
    }
    
    func didSelectEvent(_ presenter: CalendarDetailPresenter) {
        self.detailPresenter = presenter
        self.performSegue(withIdentifier: "eventdetail", sender: self)
    }
}


