//
//  String+Extensions.swift
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import Foundation
// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
private let characterEntities: [String: Character] = [
    
    // XML predefined entities:
    "&quot;"     : "\"",
    "&amp;"      : "&",
    "&apos;"     : "'",
    "&lt;"       : "<",
    "&gt;"       : ">",
    
    // HTML character entity references:
    "&nbsp;"     : "\u{00A0}",
    "&iexcl;"    : "\u{00A1}",
    "&cent;"     : "\u{00A2}",
    "&pound;"    : "\u{00A3}",
    "&curren;"   : "\u{00A4}",
    "&yen;"      : "\u{00A5}",
    "&brvbar;"   : "\u{00A6}",
    "&sect;"     : "\u{00A7}",
    "&uml;"      : "\u{00A8}",
    "&copy;"     : "\u{00A9}",
    "&ordf;"     : "\u{00AA}",
    "&laquo;"    : "\u{00AB}",
    "&not;"      : "\u{00AC}",
    "&shy;"      : "\u{00AD}",
    "&reg;"      : "\u{00AE}",
    "&macr;"     : "\u{00AF}",
    "&deg;"      : "\u{00B0}",
    "&plusmn;"   : "\u{00B1}",
    "&sup2;"     : "\u{00B2}",
    "&sup3;"     : "\u{00B3}",
    "&acute;"    : "\u{00B4}",
    "&micro;"    : "\u{00B5}",
    "&para;"     : "\u{00B6}",
    "&middot;"   : "\u{00B7}",
    "&cedil;"    : "\u{00B8}",
    "&sup1;"     : "\u{00B9}",
    "&ordm;"     : "\u{00BA}",
    "&raquo;"    : "\u{00BB}",
    "&frac14;"   : "\u{00BC}",
    "&frac12;"   : "\u{00BD}",
    "&frac34;"   : "\u{00BE}",
    "&iquest;"   : "\u{00BF}",
    "&Agrave;"   : "\u{00C0}",
    "&Aacute;"   : "\u{00C1}",
    "&Acirc;"    : "\u{00C2}",
    "&Atilde;"   : "\u{00C3}",
    "&Auml;"     : "\u{00C4}",
    "&Aring;"    : "\u{00C5}",
    "&AElig;"    : "\u{00C6}",
    "&Ccedil;"   : "\u{00C7}",
    "&Egrave;"   : "\u{00C8}",
    "&Eacute;"   : "\u{00C9}",
    "&Ecirc;"    : "\u{00CA}",
    "&Euml;"     : "\u{00CB}",
    "&Igrave;"   : "\u{00CC}",
    "&Iacute;"   : "\u{00CD}",
    "&Icirc;"    : "\u{00CE}",
    "&Iuml;"     : "\u{00CF}",
    "&ETH;"      : "\u{00D0}",
    "&Ntilde;"   : "\u{00D1}",
    "&Ograve;"   : "\u{00D2}",
    "&Oacute;"   : "\u{00D3}",
    "&Ocirc;"    : "\u{00D4}",
    "&Otilde;"   : "\u{00D5}",
    "&Ouml;"     : "\u{00D6}",
    "&times;"    : "\u{00D7}",
    "&Oslash;"   : "\u{00D8}",
    "&Ugrave;"   : "\u{00D9}",
    "&Uacute;"   : "\u{00DA}",
    "&Ucirc;"    : "\u{00DB}",
    "&Uuml;"     : "\u{00DC}",
    "&Yacute;"   : "\u{00DD}",
    "&THORN;"    : "\u{00DE}",
    "&szlig;"    : "\u{00DF}",
    "&agrave;"   : "\u{00E0}",
    "&aacute;"   : "\u{00E1}",
    "&acirc;"    : "\u{00E2}",
    "&atilde;"   : "\u{00E3}",
    "&auml;"     : "\u{00E4}",
    "&aring;"    : "\u{00E5}",
    "&aelig;"    : "\u{00E6}",
    "&ccedil;"   : "\u{00E7}",
    "&egrave;"   : "\u{00E8}",
    "&eacute;"   : "\u{00E9}",
    "&ecirc;"    : "\u{00EA}",
    "&euml;"     : "\u{00EB}",
    "&igrave;"   : "\u{00EC}",
    "&iacute;"   : "\u{00ED}",
    "&icirc;"    : "\u{00EE}",
    "&iuml;"     : "\u{00EF}",
    "&eth;"      : "\u{00F0}",
    "&ntilde;"   : "\u{00F1}",
    "&ograve;"   : "\u{00F2}",
    "&oacute;"   : "\u{00F3}",
    "&ocirc;"    : "\u{00F4}",
    "&otilde;"   : "\u{00F5}",
    "&ouml;"     : "\u{00F6}",
    "&divide;"   : "\u{00F7}",
    "&oslash;"   : "\u{00F8}",
    "&ugrave;"   : "\u{00F9}",
    "&uacute;"   : "\u{00FA}",
    "&ucirc;"    : "\u{00FB}",
    "&uuml;"     : "\u{00FC}",
    "&yacute;"   : "\u{00FD}",
    "&thorn;"    : "\u{00FE}",
    "&yuml;"     : "\u{00FF}",
    "&OElig;"    : "\u{0152}",
    "&oelig;"    : "\u{0153}",
    "&Scaron;"   : "\u{0160}",
    "&scaron;"   : "\u{0161}",
    "&Yuml;"     : "\u{0178}",
    "&fnof;"     : "\u{0192}",
    "&circ;"     : "\u{02C6}",
    "&tilde;"    : "\u{02DC}",
    "&Alpha;"    : "\u{0391}",
    "&Beta;"     : "\u{0392}",
    "&Gamma;"    : "\u{0393}",
    "&Delta;"    : "\u{0394}",
    "&Epsilon;"  : "\u{0395}",
    "&Zeta;"     : "\u{0396}",
    "&Eta;"      : "\u{0397}",
    "&Theta;"    : "\u{0398}",
    "&Iota;"     : "\u{0399}",
    "&Kappa;"    : "\u{039A}",
    "&Lambda;"   : "\u{039B}",
    "&Mu;"       : "\u{039C}",
    "&Nu;"       : "\u{039D}",
    "&Xi;"       : "\u{039E}",
    "&Omicron;"  : "\u{039F}",
    "&Pi;"       : "\u{03A0}",
    "&Rho;"      : "\u{03A1}",
    "&Sigma;"    : "\u{03A3}",
    "&Tau;"      : "\u{03A4}",
    "&Upsilon;"  : "\u{03A5}",
    "&Phi;"      : "\u{03A6}",
    "&Chi;"      : "\u{03A7}",
    "&Psi;"      : "\u{03A8}",
    "&Omega;"    : "\u{03A9}",
    "&alpha;"    : "\u{03B1}",
    "&beta;"     : "\u{03B2}",
    "&gamma;"    : "\u{03B3}",
    "&delta;"    : "\u{03B4}",
    "&epsilon;"  : "\u{03B5}",
    "&zeta;"     : "\u{03B6}",
    "&eta;"      : "\u{03B7}",
    "&theta;"    : "\u{03B8}",
    "&iota;"     : "\u{03B9}",
    "&kappa;"    : "\u{03BA}",
    "&lambda;"   : "\u{03BB}",
    "&mu;"       : "\u{03BC}",
    "&nu;"       : "\u{03BD}",
    "&xi;"       : "\u{03BE}",
    "&omicron;"  : "\u{03BF}",
    "&pi;"       : "\u{03C0}",
    "&rho;"      : "\u{03C1}",
    "&sigmaf;"   : "\u{03C2}",
    "&sigma;"    : "\u{03C3}",
    "&tau;"      : "\u{03C4}",
    "&upsilon;"  : "\u{03C5}",
    "&phi;"      : "\u{03C6}",
    "&chi;"      : "\u{03C7}",
    "&psi;"      : "\u{03C8}",
    "&omega;"    : "\u{03C9}",
    "&thetasym;" : "\u{03D1}",
    "&upsih;"    : "\u{03D2}",
    "&piv;"      : "\u{03D6}",
    "&ensp;"     : "\u{2002}",
    "&emsp;"     : "\u{2003}",
    "&thinsp;"   : "\u{2009}",
    "&zwnj;"     : "\u{200C}",
    "&zwj;"      : "\u{200D}",
    "&lrm;"      : "\u{200E}",
    "&rlm;"      : "\u{200F}",
    "&ndash;"    : "\u{2013}",
    "&mdash;"    : "\u{2014}",
    "&lsquo;"    : "\u{2018}",
    "&rsquo;"    : "\u{2019}",
    "&sbquo;"    : "\u{201A}",
    "&ldquo;"    : "\u{201C}",
    "&rdquo;"    : "\u{201D}",
    "&bdquo;"    : "\u{201E}",
    "&dagger;"   : "\u{2020}",
    "&Dagger;"   : "\u{2021}",
    "&bull;"     : "\u{2022}",
    "&hellip;"   : "\u{2026}",
    "&permil;"   : "\u{2030}",
    "&prime;"    : "\u{2032}",
    "&Prime;"    : "\u{2033}",
    "&lsaquo;"   : "\u{2039}",
    "&rsaquo;"   : "\u{203A}",
    "&oline;"    : "\u{203E}",
    "&frasl;"    : "\u{2044}",
    "&euro;"     : "\u{20AC}",
    "&image;"    : "\u{2111}",
    "&weierp;"   : "\u{2118}",
    "&real;"     : "\u{211C}",
    "&trade;"    : "\u{2122}",
    "&alefsym;"  : "\u{2135}",
    "&larr;"     : "\u{2190}",
    "&uarr;"     : "\u{2191}",
    "&rarr;"     : "\u{2192}",
    "&darr;"     : "\u{2193}",
    "&harr;"     : "\u{2194}",
    "&crarr;"    : "\u{21B5}",
    "&lArr;"     : "\u{21D0}",
    "&uArr;"     : "\u{21D1}",
    "&rArr;"     : "\u{21D2}",
    "&dArr;"     : "\u{21D3}",
    "&hArr;"     : "\u{21D4}",
    "&forall;"   : "\u{2200}",
    "&part;"     : "\u{2202}",
    "&exist;"    : "\u{2203}",
    "&empty;"    : "\u{2205}",
    "&nabla;"    : "\u{2207}",
    "&isin;"     : "\u{2208}",
    "&notin;"    : "\u{2209}",
    "&ni;"       : "\u{220B}",
    "&prod;"     : "\u{220F}",
    "&sum;"      : "\u{2211}",
    "&minus;"    : "\u{2212}",
    "&lowast;"   : "\u{2217}",
    "&radic;"    : "\u{221A}",
    "&prop;"     : "\u{221D}",
    "&infin;"    : "\u{221E}",
    "&ang;"      : "\u{2220}",
    "&and;"      : "\u{2227}",
    "&or;"       : "\u{2228}",
    "&cap;"      : "\u{2229}",
    "&cup;"      : "\u{222A}",
    "&int;"      : "\u{222B}",
    "&there4;"   : "\u{2234}",
    "&sim;"      : "\u{223C}",
    "&cong;"     : "\u{2245}",
    "&asymp;"    : "\u{2248}",
    "&ne;"       : "\u{2260}",
    "&equiv;"    : "\u{2261}",
    "&le;"       : "\u{2264}",
    "&ge;"       : "\u{2265}",
    "&sub;"      : "\u{2282}",
    "&sup;"      : "\u{2283}",
    "&nsub;"     : "\u{2284}",
    "&sube;"     : "\u{2286}",
    "&supe;"     : "\u{2287}",
    "&oplus;"    : "\u{2295}",
    "&otimes;"   : "\u{2297}",
    "&perp;"     : "\u{22A5}",
    "&sdot;"     : "\u{22C5}",
    "&lceil;"    : "\u{2308}",
    "&rceil;"    : "\u{2309}",
    "&lfloor;"   : "\u{230A}",
    "&rfloor;"   : "\u{230B}",
    "&lang;"     : "\u{2329}",
    "&rang;"     : "\u{232A}",
    "&loz;"      : "\u{25CA}",
    "&spades;"   : "\u{2660}",
    "&clubs;"    : "\u{2663}",
    "&hearts;"   : "\u{2665}",
    "&diams;"    : "\u{2666}"
    
]

public extension String {
    
    public var length: Int {
        return self.count
    }
    
    public func getCharacter(at: Int) -> Character? {
        if at < 0 || at >= self.count { return nil }
        return self[self.index(self.startIndex, offsetBy: at)]
    }
    
    public func getSubstring(from: Int = 0, to: Int? = nil) -> String? {
        var endIndex = self.endIndex
        if let t = to{
            if t < 0 || t > self.count{
                return nil
            }
            endIndex = self.index(self.endIndex, offsetBy: -(self.count - t))
        }
        
        if from < 0 || from > self.count {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let range = startIndex..<endIndex
        return String(self[range])
    }
    
    public func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    subscript (at: Int) -> Character? {
        return getCharacter(at: at)
    }
    
    subscript (range: Range<Int>) -> String? {
        return getSubstring(from: range.lowerBound, to: range.upperBound)
    }
    
    private func trimmedStringFromFormat(_ format: String) -> String {
        let strippedCount = format.reduce(0) { count, char -> Int in
            return char == "#" ? count + 1 : count
        }
        if self.count <= strippedCount {
            return self
        } else {
            return self.getSubstring(from: self.count - strippedCount) ?? self
        }
    }
    
    //maps each character from string to # in format.
    //Example: "1234567890".stringWithFormat("###-###-####") -> "123-456-7890"
    public func stringWithFormat(_ format : String, shouldTrimFront: Bool = false) -> String {
        
        let str = shouldTrimFront ? trimmedStringFromFormat(format) : self
        var res = ""
        var index = 0
        for char in format {
            if index >= str.count { break }
            if char == "#" {
                res += String(str[index] ?? "?")
                index += 1
            } else {
                res += String(char)
            }
        }
        return res
    }
    
    //removes formatting from string
    //Example: "123-456-7890".stringWithFormat("###-###-####") -> "1234567890"
    //Warning: Will remove all characters used as formatters, i.e. "1-3-456-7890".stringWithFormat("###-###-####") -> "1234567890"
    public func stringWithoutFormat(_ format: String) -> String {
        var removed = Set<Character>()
        var res = self
        for i in 0..<format.count{
            if let char = format[i]{
                if char != "#" && !removed.contains(char){
                    res = res.replacingOccurrences(of: "\(char)", with: "")
                    removed.insert(char)
                }
            }
        }
        return res
    }
    
    public func stripCharacters(basedOnRegex regex: String) -> String {
        let stripped = self.filter { char in
            return String(char).validate(regex: regex)
        }
        return String(stripped)
    }
    
    public func stringByDecodingHTMLEntities() -> String {
        
        var result = ""
        var position = self.startIndex
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self.range(of: "&", options: .literal, range: position..<self.endIndex, locale: nil) {
            result.append(String(self[position..<ampRange.lowerBound]))
            position = ampRange.lowerBound
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            if let semiRange = self.range(of: ";", options: .literal, range: position..<self.endIndex, locale: nil) {
                let entity = String(self[position..<semiRange.upperBound])
                position = semiRange.upperBound
                
                if let decoded = characterEntities[entity] {
                    result.append(decoded)
                } else {
                    result.append(entity)
                }
            } else {
                break //No matching ";"
            }
        }
        
        result.append(String(self[position..<self.endIndex]))
        
        return result
        
    }
    
    public func stringByEncodingHTMLEntities() -> String {
        
        //for now we will just use the major ones instead of going through the whole list
        
        var result = self
        
        result = result.replacingOccurrences(of: "&", with: "&amp;") //This one must be done first!
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "'", with: "&apos;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        
        return result
        
    }
    
    public func parseISO8601Duration() -> String {
        
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0
        
        if let tIndex = self.index(of: "T") {
            var duration = String(self[tIndex...])
            
            while duration.count > 1 {
                if let dur = duration.getSubstring(from: 1) {
                    duration = dur
                    
                    let scanner = Scanner.init(string: duration)
                    var value = 0
                    if scanner.scanInt(&value) {
                        if let dur = duration.getSubstring(from: scanner.scanLocation) {
                            duration = dur
                            
                            if duration.hasPrefix("H") {
                                hours = value
                            } else if duration.hasPrefix("M") {
                                minutes = value
                            } else if duration.hasPrefix("S") {
                                seconds = value
                            }
                        }
                    }
                }
            }
        }
        
        if hours > 0 {
            return String.init(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        
        return String.init(format: "%d:%02d", minutes, seconds)
        
    }
    
    public func validate(regex: String) -> Bool {
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}

public extension Collection {
    
    /// Ensure the collection is not empty.
    ///
    /// If the collection is empty, return nil. If the collection is not empty, return an optional to the collection.
    /// It is expected the optional will be unwrapped at some point.
    func ifNotEmpty() -> Self? {
        return isEmpty ? nil : self
    }
    
}

public extension Optional where Wrapped: Collection {
    
    var isEmpty: Bool {
        if let collection = self {
            return collection.isEmpty
        }
        return true
    }
    
    /// Ensure the value in the optional is not empty.
    ///
    /// If the optional is nil, return nil. If the optional is empty, return nil. If the optional has a value and the
    /// the value is not empty, return the optional. It is expected the optional will be unwrapped at some point.
    func ifNotEmpty() -> Optional {
        return isEmpty ? nil : self
    }
    
}
