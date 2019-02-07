//
//  CalendarDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

// - This class acts as a data source for all calendar related data
class CalendarDataSource {
    
    // = The calendar service request
    let request = CalendarRequest.init()
    
    func fetchEvents(_ onSuccess: @escaping (_ events: [CalendarEvent]) -> (), onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode([CalendarEvent].self, from: data))
                    }
                    catch {
                        log.error(error)
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
}
