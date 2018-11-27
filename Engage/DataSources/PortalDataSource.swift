//
//  PortalDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// - This class acts as a data source for all portal related data
class PortalDataSource: RestResponseCheckable {
    
    // - The portal request object
    let request = PortalRequest.init()
    
    // MARK: - User
    func fetchUserData(_ completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion(nil, err)
                return
            }

            do {
                
                // - Get the full portal json first
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let jsonError = JSONError.jsonObject(error: nil)

                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Get the user json from the portal json
                guard let objJson = json["user"] else {
                    let jsonError = JSONError.notFound

                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Serialize the user json back to Data and decode to user object
                let user = try JSONDecoder().decode(User.self, from: try JSONSerialization.data(withJSONObject: objJson))
                completion(user, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion(nil, jsonError)
            }
        }
    }
    
    // MARK: - Favorites
    func fetchFavorites(_ completion: @escaping (_ favorites: [Favorite], _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion([], err)
                return
            }
            
            do {
                
                // - Get the full portal json first
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion([], jsonError)
                    return
                }
                
                // - Get the favorites json from the portal json
                guard let objJson = json["favorites"] else {
                    let jsonError = JSONError.notFound
                    
                    log.error(jsonError)
                    completion([], jsonError)
                    return
                }
                
                // - Serialize the favorites json back to Data and decode to favorites objects
                let favorites = try JSONDecoder().decode([Favorite].self, from: try JSONSerialization.data(withJSONObject: objJson))
                completion(favorites, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion([], jsonError)
            }

        }
    }
    
    //MARK: - Messages
    
    func fetchMessages(_ completion: @escaping (_ messages: [Message], _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion([], err)
                return
            }
            
            do {
                
                // - Get the full portal json first
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion([], jsonError)
                    return
                }
                
                // - Get the object json from the portal json
                guard let objJson = json["messages"] else {
                    let jsonError = JSONError.notFound
                    
                    log.error(jsonError)
                    completion([], jsonError)
                    return
                }
                
                // - Serialize the messages json back to Data and decode to objects
                let messages = try JSONDecoder().decode([Message].self, from: try JSONSerialization.data(withJSONObject: objJson))
                completion(messages, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion([], jsonError)
            }
            
        }
    }
    
    // MARK: - Categories
    func fetchCategories(_ completion: @escaping (_ categories: [Category], _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion([], err)
                return
            }
            
            do {
                
                // - Get the full portal json first
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion([], jsonError)
                    return
                }
                
                // - Get the object json from the portal json
                guard let objJson = json["categories"] else {
                    let jsonError = JSONError.notFound
                    
                    log.error(jsonError)
                    completion([], jsonError)
                    return
                }
                
                // - Serialize the object json back to Data and decode to objects
                let categories = try JSONDecoder().decode([Category].self, from: try JSONSerialization.data(withJSONObject: objJson))
                completion(categories, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion([], jsonError)
            }
            
        }
    }
    
    // MARK: - Proforma
    func fetchProforma(_ completion: @escaping (_ proforma: Proforma?, _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion(nil, err)
                return
            }
            
            do {
                
                // - Get the full portal json first
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Get the object json from the portal json
                guard let objJson = json["proforma"] else {
                    let jsonError = JSONError.notFound
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Serialize the object json back to Data and decode to objects
                let proforma = try JSONDecoder().decode(Proforma.self, from: try JSONSerialization.data(withJSONObject: objJson))
                completion(proforma, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion(nil, jsonError)
            }
            
        }
    }
    
    // MARK: - Marquee
    
    func fetchMarquee(_ completion: @escaping (_ marquee: Marquee?, _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion(nil, err)
                return
            }
            
            do {
                
                // - Get the full portal json first
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Get the object json from the portal json
                guard let objJson = json["marquee"] else {
                    let jsonError = JSONError.notFound
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Serialize the object json back to Data and decode to objects
                let marquee = try JSONDecoder().decode(Marquee.self, from: try JSONSerialization.data(withJSONObject: objJson))
                completion(marquee, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion(nil, jsonError)
            }
            
        }
    }
    
    func fetchSupportContact(_ completion: @escaping (_ contact: Contact?, _ error: Error?) -> ()) {
        request.sendRequest { (response, data, error) in
            if let err = self.checkResponse(response, data, error) {
                completion(nil, err)
                return
            }
            
            do {
                
                // - Get the full portal json first
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let jsonError = JSONError.jsonObject(error: nil)
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Get the object json from the portal json
                guard let objJson = json["contact"] else {
                    let jsonError = JSONError.notFound
                    
                    log.error(jsonError)
                    completion(nil, jsonError)
                    return
                }
                
                // - Serialize the object json back to Data and decode to objects
                let contactInfo = try JSONDecoder().decode(Contact.self, from: try JSONSerialization.data(withJSONObject: objJson))
                completion(contactInfo, nil)
                
            }
            catch {
                let jsonError = JSONError.exception(error: error)
                log.error(jsonError)
                completion(nil, jsonError)
            }
        }
    }
}
