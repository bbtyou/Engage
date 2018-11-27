//
//  CalendarDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// - This class acts as a data source for all calendar related data
class CalendarDataSource: RestResponseCheckable {
    
    // = The calendar service request
    let request = CalendarRequest.init()
    
    func fetchEvents(_ completion: @escaping (_ calendar: [CalendarEvent], _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion([], err)
                return
            }
            
            do {
                
                // - Get the calendar json from the data
                guard let data = data else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion([], jsonError)
                    return
                }
                
                // - Serialize the user json back to Data and decode to user object
                let calendar = try JSONDecoder().decode([CalendarEvent].self, from: data)
                completion(calendar, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion([], jsonError)
            }
        }
    }

}
