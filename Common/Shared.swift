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

struct WorldLocal {
    // Base server path
    var base = { Properties<String>.basepath.value ?? "" }
    
    /// Provisioning code
    var code = { Properties<String>.provisioningCode.value ?? "" }
    
    // Relative path for the logo
    var logopath = { Properties<String>.logoUrl.value ?? "" }
    
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
    
    // - File collection
    var collateral = { CollateralFile() }
    
    // All image requests
    var image = { Image() }
}

#if DEBUG
var CurrentLocal = WorldLocal()
#else
let CurrentLocal = WorldLocal()
#endif

// MARK: - Request calls

// - These calls are now implemented as structs which will transform the results of the request into a result closure.
// - Each of these variables can have their implementation swapped out for unit testing.
struct Authentication {
    var authenticate: (_ username: String, _ password: String, _ closure: @escaping ResultClosure<Login>) -> () = { username, password, closure in
        Request<Login>(path: "\(CurrentLocal.base)/api/authenticate", .shared, .post, ["login": username, "passwd": password], nil, .url).send({ (result) in
            closure(result)
        })
    }
}

struct Provisioning {
    var provision: (_ code: String, _ closure: @escaping ResultClosure<Provision>) -> () = { code, closure in
        Request<Provision>(path: "https://myengageapp.com/provision.json", .shared, .post, ["code": code], nil, .url).send({ (result) in
            closure(result)
        })
    }
}

struct Theming {
    var theme: (_ closure: @escaping ResultClosure<Theme>) -> () = { closure in
        Request<Theme>(path: "\(CurrentLocal.base)/theme.json").send({ (result) in
            closure(result)
        })
    }
}

struct Main {
    var portal: (_ useCache: Bool, _ closure: @escaping ResultClosure<Portal>) -> () = { useCache, closure in
        let path = "\(CurrentLocal.base)/portal.json"

        if !useCache {
            Request<Portal>(path: path).send({ (result) in
                closure(result)
            })
            
            return
        }
        
        Current.dataCache().item(forKey: path, { (codable) in
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
                
                Request<Portal>(path: path).send({ (result) in
                    switch result {
                    case .success(let portal):
                        try? (portal as? Cacheable)?.persist(withKey: path)
                        
                    default:
                        break
                    }
                    
                    closure(result)
                })
            }
        })
    }
}

struct SetFavorite {
    var set: (_ id: String, _ closure: @escaping ResultClosure<String>) -> () = { id, closure in
        Request<PostResult>(path: "\(CurrentLocal.base)/api/setfavorite", .shared, .post, ["id": id], nil, .url).send({ (result) in
            switch result {
            case .success(let success):
                if let set = success.ok, set == true {
                    closure(.success(id))
                }
                else {
                    closure(.success(success.failure ?? id))
                }
                
            case .failure(let error):
                closure(.failure(error))
            }
        })
    }
}

struct UnsetFavorite {
    var unset: (_ id: String, _ closure: @escaping ResultClosure<String>) -> () = { id, closure in
        Request<PostResult>(path: "\(CurrentLocal.base)/api/unsetfavorite", .shared, .post, ["id": id], nil, .url).send({ (result) in
            switch result {
            case .success(let success):
                if let unset = success.ok, unset == true {
                    closure(.success(id))
                }
                else {
                    closure(.success(success.failure ?? id))
                }
                
            case .failure(let error):
                closure(.failure(error))
            }
        })
    }
}

struct CollateralFile {
    var download: (_ path: String, _ closure: @escaping ResultClosure<Data>) -> () = { path, closure in
        Request<Data>(path: "\(CurrentLocal.base)/\(path)").send({ (result) in
            closure(result)
        })
    }
}

struct Image {
    var image: (_ closure: @escaping ResultClosure<(UIImage, String)>) -> () = { closure in
        ImageRequest(path: "\(CurrentLocal.base)/\(CurrentLocal.logopath)").send({ (result) in
            closure(result)
        })
    }
}
