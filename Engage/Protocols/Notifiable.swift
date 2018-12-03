//
//  Notifiable.swift
//  Adapt SEG
//
//  Created by Charles Imperato on 4/7/18.
//  Copyright © 2018 Adapt. All rights reserved.
//

import Foundation
import UIKit

// This protocol defines an animated banner that can come in from the top of a view.
protocol Notifiable: class {
    
    // The view that actually makes up the banner
    var notifyContainer: UIView? { get set }

}

extension Notifiable where Self: UIViewController {
    
    func notify(message: String, _ time: TimeInterval) {
        self.notifyContainer?.removeFromSuperview()
        self.notifyContainer = nil
        self.notifyContainer = UIView.init(frame: .zero)
        self.notifyContainer?.translatesAutoresizingMaskIntoConstraints = false
        self.notifyContainer?.backgroundColor = AppConfigurator.shared.themeConfigurator?.themeColor
        
        guard let container = self.notifyContainer else {
            log.warning("The banner could not be displayed because the container view could not be instantiated.")
            return
        }
        
        let textLabel = UILabel.init(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = UIColor.white
        textLabel.font = UIFont.init(name: "Helvetica-Medium", size: 15)
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 2
        textLabel.text = message
        
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = CommonImages.notify.image?.maskedImage(with: UIColor.white)

        container.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        imageView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 15).isActive = true
        imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        container.addSubview(textLabel)
        textLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 12).isActive = true
        textLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8).isActive = true
        textLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -8).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8).isActive = true
        
        self.view.addSubview(container)
        self.view.bringSubviewToFront(container)
        container.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let bottomAnchor = container.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        bottomAnchor.isActive = true

        self.view.layoutIfNeeded()

        bottomAnchor.constant = (UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.size.height ?? 44) + 44.5)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                    bottomAnchor.constant = 0
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                    })
                })
            }
        }
    }
}
