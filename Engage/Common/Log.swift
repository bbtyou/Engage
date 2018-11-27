//
//  Log.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// - Logging types
enum LogEvent: String {
    case error = "[ERROR]"
    case info = "[INFO]"
    case debug = "[DEBUG]"
    case verbose = "[VERBOSE]"
    case warning = "[WARNING]"
    case severe = "[SEVERE]"
}

// MARK: - Logging protocols
fileprivate protocol ConsoleLoggable {}

fileprivate extension ConsoleLoggable where Self: Log {
    // - Logs a message
    func logToConsole(logEvent: LogEvent, _ object: Any, filename: String, line: Int, funcName: String) {
        print("\(Date().toString()) \(logEvent.rawValue)[\(self.sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(object)")
    }
}

fileprivate protocol FileLoggable {}

fileprivate extension FileLoggable where Self: Log {
    private var logFileExists: Bool {
        get {
            if let path = self.logFilePath {
                if let reachable = try? path.checkResourceIsReachable(), reachable == true {
                    return true
                }
            }
            
            return false
        }
    }
    
    private var logFilePath: URL? {
        get {
            if let logsPath = self.logsPath {
                return logsPath.appendingPathComponent("applog").appendingPathExtension("log")
            }
            
            return nil
        }
    }
    
    private var logsPath: URL? {
        get {
            if let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                return URL.init(fileURLWithPath: documents).appendingPathComponent("log")
            }
            
            return nil
        }
    }
    
    func logToFile(logEvent: LogEvent, _ object: Any, filename: String, line: Int, funcName: String) {
        DispatchQueue.global(qos: .default).async {
            // - Get a handle to the file
            if let logFilePath = self.logFilePath {
                if self.logFileExists == false {
                    self.createLogFile()
                }
                else {
                    // Get the file size
                    if let fileAttrs = try? FileManager.default.attributesOfItem(atPath: logFilePath.path), let size = fileAttrs[FileAttributeKey.size] as? Int {
                        if size >= 1000000 {
                            NSLog("The file has exceeded its limit and will be cleared.")
                            self.createLogFile()
                        }
                    }
                }
                
                if self.logFileExists, let fileHandle = try? FileHandle.init(forUpdating: logFilePath){
                    let contents = "\(Date().toString()) \(logEvent.rawValue)[\(self.sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(object)"
                    
                    if let data = contents.data(using: .utf8) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.synchronizeFile()
                        fileHandle.closeFile()
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    private func createLogDirectory() {
        if let reachable = try? self.logsPath?.checkResourceIsReachable(), reachable == true {
            return
        }
        
        if let path = self.logsPath {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                NSLog("The logs directory could not be created. \(error).")
            }
        }
    }
    
    private func createLogFile() {
        self.createLogDirectory()
        
        if let logFilePath = self.logFilePath {
            if self.logFileExists {
                do {
                    // - Delete the file if it is alread there
                    try FileManager.default.removeItem(at: logFilePath)
                }
                catch {
                    NSLog("Unable delete the existing log file. \(error).")
                }
            }
            
            // - Create a new file
            if FileManager.default.createFile(atPath: logFilePath.path, contents: nil, attributes: nil) {
                NSLog("Successfully created file log.")
            }
            else {
                NSLog("Unable to create the file log.")
            }
        }
        else {
            NSLog("The log file could not be created because the path was invalid.")
        }
    }
}

fileprivate extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}

class Log: ConsoleLoggable, FileLoggable {
    
    fileprivate static var dateFormat = "yyyy-MM-dd hh:mm:ss"
    fileprivate static var dateFormatter: DateFormatter {
        get {
            let formatter = DateFormatter()

            formatter.dateFormat = dateFormat
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current

            return formatter
        }
    }
    
    // - Enable or disable logging
    var enabled: Bool = true
    
    // MARK: - log methods
    func error(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        self.log(logEvent: .error, object: object, filename: filename, line: line, funcName: funcName)
    }
    
    func info(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        self.log(logEvent: .info, object: object, filename: filename, line: line, funcName: funcName)
    }

    func debug(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        self.log(logEvent: .debug, object: object, filename: filename, line: line, funcName: funcName)
    }

    func warning(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        self.log(logEvent: .warning, object: object, filename: filename, line: line, funcName: funcName)
    }

    func verbose(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        self.log(logEvent: .verbose, object: object, filename: filename, line: line, funcName: funcName)
    }

    func severe(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        self.log(logEvent: .severe, object: object, filename: filename, line: line, funcName: funcName)
    }

    // MARK: - Private
    private func log(logEvent: LogEvent, object: Any, filename: String, line: Int, funcName: String) {
        if self.enabled {
            // - Log to console
            self.logToConsole(logEvent: logEvent, object, filename: filename, line: line, funcName: funcName)
            
            // - Log to file
            self.logToFile(logEvent: logEvent, object, filename: filename, line: line, funcName: funcName)
        }
    }
    
    fileprivate func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : (components.last ?? "")
    }
}
