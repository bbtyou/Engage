//
//  FileManager+Extensions.swift
//  GMCommon
//
//  Created by Chuck Imperato on 11/16/18.
//  Copyright © 2018 General Motors. All rights reserved.
//

import Foundation

// - Sort the files by this element
enum FileSortBy: Int {
	case modificationDate
	case size
}

extension FileManager {
	
	// - Returns the file contents of a directory sorted by either the last modification date or the size of the file.
	func contents(forPath path: String, _ sortBy: FileSortBy = .modificationDate, sortAscending: Bool = true) -> [String] {
		var sorted = [String]()
		
		do {
			
			let contents = try self.contentsOfDirectory(atPath: path)
			
			// - Store the paths of all of the files
			let paths = contents.map { (file) -> String in
				return path + "/\(file)"
			}
			
			// - Sort the paths based on the criteria
			sorted = paths.sorted { (path1, path2) -> Bool in
				do {
					
					// - Get the attributes of each
					let path1Attr = try self.attributesOfItem(atPath: path1)
					let path2Attr = try self.attributesOfItem(atPath: path2)
					
					// - Sort by modification date
					if sortBy == .modificationDate {
						if let date1 = path1Attr[FileAttributeKey.modificationDate] as? Date, let date2 = path2Attr[FileAttributeKey.modificationDate] as? Date {
							return sortAscending ?
								date1.timeIntervalSince1970 > date2.timeIntervalSince1970 :
								date1.timeIntervalSince1970 < date2.timeIntervalSince1970
						}
						
						return false
					}
					else if sortBy == .size { // Sort by size
						if let size1 = path1Attr[FileAttributeKey.size] as? UInt64, let size2 = path2Attr[FileAttributeKey.size] as? UInt64 {
							return (sortAscending) ? size1 > size2 : size1 < size2
						}
					}
					
				}
				catch {
					log.error("Unable to obtain attributes for files at \(path1) and \(path2) when attempting to sort.")
				}
				
				return true
			}
			
		}
		catch {
			log.error("Unable to obtain the contents of director \(path)")
		}
		
		return sorted
	}
}
