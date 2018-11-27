//
//  Containerable.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import Foundation
import UIKit

// - Defines the ability for a view controller to contain another view controller.
protocol Containerable: class {
	
	// - Detail view controller
	var detailView: UIViewController? { get set }
	
	// - Container view
	var container: UIView? { get set }
		
}

// MARK: - UIViewController

extension Containerable where Self: UIViewController {
	
	func addDetailView(_ detail: UIViewController) {
		guard let container = self.container else {
			return
		}
		
		self.addChild(detail)
		
		// - Remove any other child view before adding a new one
		self.removeDetailView()
		self.view.addSubview(detail.view)
		
		// - create the constraints for the newly added view
		detail.view.translatesAutoresizingMaskIntoConstraints = false
		detail.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
		detail.view.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
		detail.view.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
		detail.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true

		detail.didMove(toParent: self)
        
        self.detailView = detail
	}
	
	func removeDetailView() {
		guard let detailView = self.detailView else {
			return
		}

		detailView.willMove(toParent: nil)
		detailView.view.removeFromSuperview()
		detailView.removeFromParent()
	}
	
}
