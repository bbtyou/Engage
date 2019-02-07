//
//  PortalDataSource.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import wvslib

// - This class acts as a data source for all portal related data
class PortalDataSource {
    
    // - The portal request object
    let request = PortalRequest.init()
    
    // MARK: - User
    func fetchUserData(_ onSuccess: @escaping (_ user: User?) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode(User.self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
    
    // MARK: - Favorites
    func fetchFavorites(_ onSuccess: @escaping (_ favorites: [Favorite]) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode([Favorite].self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
    
    
    //MARK: - Messages
    func fetchMessages(_ onSuccess: @escaping (_ messages: [Message]) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode([Message].self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
    
    // MARK: - Categories
    func fetchCategories(_ onSuccess: @escaping (_ categories: [Category]) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode([Category].self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
    
    // MARK: - Proforma
    func fetchProforma(_ onSuccess: @escaping (_ proforma: Proforma) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
        
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode(Proforma.self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }


    // MARK: - Marquee
    func fetchMarquee(_ onSuccess: @escaping (_ marquee: Marquee) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode(Marquee.self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
    
    // MARK: - Support Contact
    func fetchSupportContact(_ onSuccess: @escaping (_ contact: Contact) -> (), _ onFailure: @escaping (_ error: String) -> ()) {
        self.request.sendRequest { (result) in
            switch result {
                case .error(let error):
                    onFailure(error.localizedDescription)
                
                case .success(let data):
                    do {
                        onSuccess(try JSONDecoder().decode(Contact.self, from: data))
                    }
                    catch {
                        onFailure(error.localizedDescription)
                    }
            }
        }
    }
}
