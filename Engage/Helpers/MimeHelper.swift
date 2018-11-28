//
//  MimeHelper.swift
//  Engage
//
//  Created by Charles Imperato on 11/18/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

class MimeMap {
    static let shared = MimeMap()
    
    // - The plist map
    fileprivate var pList: [String: String]?
    
    private init() {
        // Load the property list data
        let pListFileURL = Bundle.main.url(forResource: "Mime-Mapping", withExtension: "plist", subdirectory: "")
        
        if let pListPath = pListFileURL?.path, let pListData = FileManager.default.contents(atPath: pListPath) {
            do {
                let pListObject = try PropertyListSerialization.propertyList(from: pListData, options:PropertyListSerialization.ReadOptions(), format:nil)

                // - Get the plist dictionary
                guard let pListDict = pListObject as? [String: String] else {
                    return
                }
                
                self.pList = pListDict
            }
            catch {
                log.error("Unable to read mime mappings from plist file: \(error)")
            }
        }
    }
    
    // - Returns the file extension for the specified mime type.  If the type cannot be determined
    // - the default return type is "pdf".
    func pathExtension(forMime type: String) -> String {
        return self.pList?[type] ?? "pdf"
    }
    
    // - Returns the mime type for the path
    func mime(forExtension pathExt: String) -> String {
        var mimeType: String = "application/pdf"
        
        self.supportedMimeTypes().forEach { (mime) in
            if self.pathExtension(forMime: mime) == pathExt {
                mimeType = mime
            }
        }
        
        return mimeType
    }
    
    func supportedMimeTypes() -> [String] {
        return self.pList?.keys.map({ (key) -> String in
            return key
        }) ?? []
    }
}
