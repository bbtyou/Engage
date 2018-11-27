//
//  Data+Extensions.swift
//  Adapt SEG
//
//  Created by Charles Imperato on 7/8/18.
//  Copyright © 2018 Adapt. All rights reserved.
//

import Foundation
import Security

public extension Data {
    
    public var SHA256Digest: String? {
        get {
            var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
            self.withUnsafeBytes {
                _ = CC_SHA256($0, CC_LONG(self.count), &hash)
            }
            let sha1 = Data(bytes: hash, count:Int(CC_SHA256_DIGEST_LENGTH))
            
            var bytes = [UInt8](repeating: 0, count: sha1.count)
            sha1.copyBytes(to: &bytes, count: sha1.count)
            
            var fileName = ""
            for byte in bytes {
                fileName += String(format: "%0x", UInt8(byte))
            }
            return fileName
        }
    }
    
}
