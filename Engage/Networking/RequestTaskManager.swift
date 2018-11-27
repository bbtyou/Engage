//
//  RequestTaskManager.swift
//  Engage
//
//  Created by Charles Imperato on 11/9/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation

// - This class manages the service requests that are currently in progress
class RequestTaskManager {
    
    // - Singleton
    static let shared = RequestTaskManager()

    // - Dispatch Queue for modifying the map
    let queue = DispatchQueue.init(label: "com.engage.taskQueue", attributes: .concurrent)

    var taskMap = [String: URLSessionDataTask]()

    private init() {}
    
    func addTask(_ task: URLSessionDataTask) {
        guard let taskId = task.taskDescription else {
            log.warning("Task was not run because it did not have a valid identifier.")
            return
        }
        
        self.queue.async(flags: .barrier) { [weak self] in
            self?.taskMap[taskId]?.cancel()
            self?.taskMap.removeValue(forKey: taskId)
            self?.taskMap[taskId] = task
            task.resume()
        }
    }
    
    func cancel(taskId id: String) {
        self.queue.async(flags: .barrier) { [weak self] in
            self?.taskMap[id]?.cancel()
            self?.taskMap.removeValue(forKey: id)
        }
    }
    
    func suspend(taskId id: String) {
        self.queue.sync {
            self.taskMap[id]?.suspend()
        }
    }
    
    func clear() {
        self.queue.async(flags: .barrier) { [weak self] in
            self?.taskMap.values.forEach({ (task) in
                task.cancel()
            })
            
            self?.taskMap.removeAll()
        }
    }

    func suspendAll() {
        self.queue.sync {
            self.taskMap.values.forEach({ (task) in
                task.suspend()
            })
        }
    }
    
    func resumeAll() {
        self.queue.sync {
            self.taskMap.values.forEach({ (task) in
                task.resume()
            })
        }
    }
}

