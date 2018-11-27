//
//  Waitable.swift
//  Engage
//
//  Created by Charles Imperato on 11/12/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

/// This protocol specifies that a view can have a wait spinner
/// associated with it.
protocol Waitable: class {
    
    // - Boolean which states if the spinner is active
    var isWaitableActive: Bool { get }
    
    // - Shows the wait spinner
    func showSpinner(_ message: String?)
    
    // - Hides and removes the wait spinner
    func hideSpinner()
}

extension Waitable where Self: UIViewController {
    
    var isWaitableActive: Bool {
        get {
            guard let window = UIApplication.shared.windows.first else {
                // Fatal error if we don't have a window
                log.severe("A catastrophic error occurred because the window could not be found.")
                return false
            }
            
            if let _ = window.viewWithTag(self.viewTag) {
                return true
            }
            
            return false
        }
    }
    
    fileprivate var viewTag: Int {
        get {
            return 110
        }
    }
    
    func showSpinner(_ message: String?) {
        if self.isWaitableActive {
            self.hideSpinner()
        }
        
        let overlayView = UIView()
        
        guard let window = UIApplication.shared.windows.first else {
            log.severe("Unable to display wait spinner because the window could not be found.")
            return
        }
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.colorWithHexValue(hex: "000000", alpha: 0.5)
        overlayView.tag = self.viewTag
        overlayView.alpha = 0
        
        window.addSubview(overlayView)
        overlayView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
        overlayView.leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true
        overlayView.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        
        var view: UIView?
        
        let customSpinner = UIImageView(frame: .zero)
        customSpinner.animationImages = CommonImages.loadspinner.imageSequence
        
        overlayView.addSubview(customSpinner)
        overlayView.bringSubviewToFront(customSpinner)
        
        customSpinner.translatesAutoresizingMaskIntoConstraints = false
        customSpinner.widthAnchor.constraint(equalToConstant: 50).isActive = true
        customSpinner.heightAnchor.constraint(equalToConstant:50).isActive = true
        customSpinner.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        customSpinner.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        
        customSpinner.animationDuration = 0.75
        customSpinner.startAnimating()
        
        view = customSpinner
        
        guard let waitView = view else {
            log.error("An unexpected error occurred.  The spinner was not valid.")
            return
        }
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.addSubview(label)
        label.topAnchor.constraint(equalTo: waitView.bottomAnchor, constant: 10.0).isActive = true
        label.leftAnchor.constraint(equalTo: overlayView.leftAnchor, constant: 20.0).isActive = true
        label.rightAnchor.constraint(equalTo: overlayView.rightAnchor, constant: -20.0).isActive = true
        
        UIView.animate(withDuration: 0.25) {
            overlayView.alpha = 1.0
        }
    }
    
    func hideSpinner() {
        guard let window = UIApplication.shared.windows.first else {
            // Fatal error if we don't have a window
            log.severe("A catastrophic error occurred because the window could not be found.")
            return
        }
        
        if let spinnerOverlay = window.viewWithTag(self.viewTag) {
            UIView.animate(withDuration: 0.25) {
                spinnerOverlay.alpha = 0.0
            }
            
            spinnerOverlay.isHidden = true
            spinnerOverlay.removeFromSuperview()
        }
    }
    
}

extension Waitable where Self: UIView {
    
    fileprivate var viewTag: Int {
        get {
            return 210
        }
    }
    
    var isWaitableActive: Bool {
        get {
            if let _ = self.viewWithTag(self.viewTag) {
                return true
            }
            
            return false
        }
    }
    
    func showSpinner(_ message: String?){
        if self.isWaitableActive {
            self.hideSpinner()
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let overlayView = UIView()
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.clear
        overlayView.tag = self.viewTag
        overlayView.alpha = 0
        
        self.addSubview(overlayView)
        overlayView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        overlayView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        overlayView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        var view: UIView?
        
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        spinner.startAnimating()
        
        view = spinner
        
        guard let waitView = view else {
            log.error("An unexpected error occurred.  The spinner was not valid.")
            return
        }

        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.addSubview(label)
        label.topAnchor.constraint(equalTo: waitView.bottomAnchor, constant: 10.0).isActive = true
        label.leftAnchor.constraint(equalTo: overlayView.leftAnchor, constant: 10.0).isActive = true
        label.rightAnchor.constraint(equalTo: overlayView.rightAnchor, constant: -10.0).isActive = true
        
        UIView.animate(withDuration: 0.25) {
            overlayView.alpha = 1.0
        }
        
    }
    
    func hideSpinner() {
        if let spinnerOverlay = self.viewWithTag(self.viewTag) {
            UIView.animate(withDuration: 0.25) {
                spinnerOverlay.alpha = 0.0
            }
            
            spinnerOverlay.isHidden = true
            spinnerOverlay.removeFromSuperview()
        }
    }
    
}
