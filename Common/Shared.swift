//
//  Shared.swift
//  Engage
//
//  Created by Charles Imperato on 2/19/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit
import wvslib

fileprivate struct Shared {
    // REST cache
    static let restCache = DefaultCache<CodableData>(name: "engage-rest-cache")
    
    // Images cache
    static let imageCache = DefaultCache<CodableImage>(name: "engage-image-cache")
    
    // - Logger
    static let log = Log()
}

struct World {
    
    // Log
    var log = { Shared.log }
    
    // Rest response cache
    var restCache = { Shared.restCache }
    
    // Image cache
    var imageCache = { Shared.imageCache }
    
    // Base server path
    var base = { return Properties.basepath.value ?? "" }
    
    /// Provisioning code
    var code = { return Properties.provisioningCode.value ?? "" }
    
    // Relative path for the logo
    var logopath = { return Properties.logoUrl.value ?? "" }
    
    /// Authentication
    var auth = { Authentication() }
    
    /// Provisioning
    var provisioning = { Provisioning() }
    
    // Theming
    var theming = { Theming() }
    
    // Main portal
    var main = { Main() }
    
    // Set a favorite
    var setFavorite = { SetFavorite() }
    
    // Unset a favorite
    var unsetFavorite = { UnsetFavorite() }
    
    // Mark a message as read
    var messageAction = { MessageAction() }
    
    // Register for push
    var registerPush = { RegisterPush() }
    
    // - File collection
    var collateral = { CollateralFile() }
    
    // - Calendar
    var calendar = { Calendar() }
    
    // All image requests
    var image = { Image() }
}

#if DEBUG
var Current = World()
#else
let Current = World()
#endif

// MARK: - Request calls

// - These calls are now implemented as structs which will transform the results of the request into a result closure.
// - Each of these variables can have their implementation swapped out for unit testing.
struct Authentication {
    var authenticate: (_ username: String, _ password: String, _ closure: @escaping ResultClosure<Login>) -> () = { username, password, closure in
        Request<Login>(base: Current.base(), path: "/api/authenticate", .shared, .post, ["login": username, "passwd": password], nil, .url).send({ (result) in
            DispatchQueue.main.async {
                closure(result)
            }
        })
    }
}

struct Provisioning {
    var provision: (_ code: String, _ closure: @escaping ResultClosure<Provision>) -> () = { code, closure in
        Request<Provision>(base: "https://myengageapp.com", path: "/provision.json", .shared, .post, ["code": code], nil, .url).send({ (result) in
            DispatchQueue.main.async {
                closure(result)
            }
        })
    }
}

struct Theming {
    var theme: (_ closure: @escaping ResultClosure<Theme>) -> () = { closure in
        Request<Theme>(base: Current.base(), path: "/theme.json").send({ (result) in
            DispatchQueue.main.async {
                closure(result)
            }
        })
    }
}

struct Main {
    var portal: (_ useCache: Bool, _ closure: @escaping ResultClosure<Portal>) -> () = { useCache, closure in
        if !useCache {
            Request<Portal>(base: Current.base(), path: "/portal.json").send({ (result) in
                do {
                    let encoder = JSONEncoder()
                    Current.restCache().set(CodableData(data: try encoder.encode(result.get())), forKey: "\(Current.base())/portal.json")
                }
                catch {
                    Current.log().error("Unable to cache portal data: \(error).")
                }
                
                DispatchQueue.main.async {
                    closure(result)
                }
            })
            
            return
        }
        
        Current.restCache().item(forKey: "\(Current.base())/portal.json", { (codable) in
            DispatchQueue.main.async {
                if let data = codable?.data {
                    do {
                        let decoder = JSONDecoder()
                        let portal = try decoder.decode(Portal.self, from: data)
                        closure(.success(portal))
                        return
                    }
                    catch {
                        Current.log().error(error)
                    }
                }
            }
        })
    }
}

struct SetFavorite {
    var set: (_ id: String, _ closure: @escaping ResultClosure<String>) -> () = { id, closure in
        Request<PostResult>(base: Current.base(), path: "/api/setfavorite", .shared, .post, ["id": id], nil, .url).send({ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if let set = success.ok, set == 1 {
                        closure(.success(id))
                    }
                    else {
                        closure(.success(success.failure ?? id))
                    }
                    
                case .failure(let error):
                    closure(.failure(error))
                }
            }
        })
    }
}

struct UnsetFavorite {
    var unset: (_ id: String, _ closure: @escaping ResultClosure<String>) -> () = { id, closure in
        Request<PostResult>(base: Current.base(), path: "/api/unsetfavorite", .shared, .post, ["id": id], nil, .url).send({ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if let unset = success.ok, unset == 1 {
                        closure(.success(id))
                    }
                    else {
                        closure(.success(success.failure ?? id))
                    }
                    
                case .failure(let error):
                    closure(.failure(error))
                }
            }
        })
    }
}

struct MessageAction {
    var markRead: (_ id: String, _ closure: @escaping ResultClosure<String>) -> () = { id, closure in
        Request<PostResult>(base: Current.base(), path: "/api/messageread", .shared, .post, ["id": id], nil, .url).send({ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if let read = success.ok, read == 1 {
                        closure(.success(id))
                    }
                    else {
                        closure(.success(success.failure ?? id))
                    }
                    
                case .failure(let error):
                    closure(.failure(error))
                }
            }
        })
    }
    
    var delete: (_ id: String, _ closure: @escaping ResultClosure<String>) -> () = { id, closure in
        Request<PostResult>(base: Current.base(), path: "/api/messagedelete", .shared, .post, ["id": id], nil, .url).send({ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if let read = success.ok, read == 1 {
                        closure(.success(id))
                    }
                    else {
                        closure(.success(success.failure ?? id))
                    }
                    
                case .failure(let error):
                    closure(.failure(error))
                }
            }
        })
    }
}

struct RegisterPush {
    var push: (_ id: String, _ closure: @escaping ResultClosure<String>) -> () = { id, closure in
        Request<PostResult>(base: Current.base(), path: "/api/register", .shared, .post, ["id": id], nil, .url).send({ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if let reg = success.ok, reg == 1 {
                        closure(.success(id))
                    }
                    else {
                        closure(.success(success.failure ?? id))
                    }
                    
                case .failure(let error):
                    closure(.failure(error))
                }
            }
        })
    }
}

struct CollateralFile {
    var download: (_ base: String, _ path: String, _ closure: @escaping ResultClosure<Data>) -> () = { basepath, path, closure in
        // Check the cache first
        Current.restCache().item(forKey: "\(Current.base())/\(path)", { (data) in
            guard let data = data?.data else {
                DataRequest(base: Current.base(), path: path).send({ (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            Current.restCache().set(CodableData(data: data), forKey: "\(Current.base())/\(path)")
                            
                        default:
                            break
                        }
                        
                        closure(result)
                    }
                })
                return
            }
            
            DispatchQueue.main.async {
                closure(.success(data))
            }
        })
    }
}

struct Calendar {
    var cal: (_ closure: @escaping ResultClosure<[CalendarEvent]>) -> () = { closure in
        Request<[CalendarEvent]>.init(base: Current.base(), path: "/calendar.json").send({ (result) in
            DispatchQueue.main.async {
                closure(result)
            }
        })
    }
}

struct Image {
    var logo: (_ closure: @escaping ResultClosure<(UIImage, String)>) -> () = { closure in
        // Check the cache first
        Current.imageCache().item(forKey: "\(Current.base())/\(Current.logopath())", { (codable) in
            guard let image = codable?.image else {
                ImageRequest(base: Current.base(), path: Current.logopath()).send({ (result) in
                    DispatchQueue.main.async {
                        closure(result)
                    }
                })
                
                return
            }
            
            DispatchQueue.main.async {
                closure(.success((image, "\(Current.base)/\(Current.logopath())")))
            }
        })
    }
}
