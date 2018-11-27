//
//  Date+Extensions.swift
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import Foundation

extension Date {
    
    static func dateFromUTCString(utc: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatter.date(from: utc)
    }
    
    static func localTimeFromDate(utc: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // - Get the date from the string in UTC
        if let date = formatter.date(from: utc) {
            
            // - Get the local date as a string
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "hh:mm a"
            
            return formatter.string(from: date)
        }
        
        return "12:00 pm"
    }
    
    static func localYearFromDate(utc: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // - Get the date from the string in UTC
        if let date = formatter.date(from: utc) {
            
            // - Get the local date as a string
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy"
            
            return formatter.string(from: date)
        }
        
        return String(Calendar.current.component(.year, from: Date()))
    }
    
    static func dayFromUTCString(_ utc: String) -> Int {
        if let date = Date.dateFromUTCString(utc: utc) {
            return Calendar.current.component(.day, from: date)
        }
        
        return 1
    }
    
    static func monthFromUTCString(_ utc: String) -> Int {
        if let date = Date.dateFromUTCString(utc: utc) {
            return Calendar.current.component(.month, from: date)
        }
        
        return 1
    }
    
    static func yearFromUTCString(_ utc: String) -> String {
        return Date.localYearFromDate(utc: utc)
    }
    
    static func timeFromUTCString(_ utc: String) -> String {
        return Date.localTimeFromDate(utc: utc)
    }
    
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    var relativeTime: String {
        let now = Date()
        
        if now.years(from: self)   > 0 {
            return now.years(from: self).description  + " year"  + { return now.years(from: self)   > 1 ? "s" : "" }() + " ago"
        }
        
        if now.months(from: self)  > 0 {
            return now.months(from: self).description + " month" + { return now.months(from: self)  > 1 ? "s" : "" }() + " ago"
        }
        
        if now.weeks(from:self)   > 0 {
            return now.weeks(from: self).description  + " week"  + { return now.weeks(from: self)   > 1 ? "s" : "" }() + " ago"
        }
        
        if now.days(from: self)    > 0 {
            if now.days(from:self) == 1 { return "Yesterday" }
            return now.days(from: self).description + " days ago"
        }
        
        if now.hours(from: self)   > 0 {
            return "\(now.hours(from: self)) hour"     + { return now.hours(from: self)   > 1 ? "s" : "" }() + " ago"
        }
        
        if now.minutes(from: self) > 0 {
            return "\(now.minutes(from: self)) minute" + { return now.minutes(from: self) > 1 ? "s" : "" }() + " ago"
        }
        
        if now.seconds(from: self) > 0 {
            if now.seconds(from: self) < 15 { return "Just now"  }
            return "\(now.seconds(from: self)) second" + { return now.seconds(from: self) > 1 ? "s" : "" }() + " ago"
        }
        
        return ""
    }
    
    // Checks if the date is in the past
    var inThePast: Bool {
        return timeIntervalSinceNow < 0
    }
}
