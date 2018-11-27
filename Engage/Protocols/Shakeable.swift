//
//  Shakeable.swift
//  Engage
//
//  Created by Chuck Imperato on 11/13/18.
//  Copyright © 2018 PerpetuityMD. All rights reserved.
//

import UIKit

// - Shake direction can be horizontal or vertical
enum ShakeDirection: Int {
	case horizontal = 1
	case vertical
}

// - Completion type alias
typealias ShakeComplete = ((_ finished: Bool) -> ())

// - Defines an object that can perform a "shake" animation
protocol Shakeable {
	
	// - Shake the object
	func shake(_ direction: ShakeDirection, _ completion: ShakeComplete?)
	
}

extension Shakeable where Self: UIView {
	
	func shake(_ direction: ShakeDirection, _ completion: ShakeComplete? = nil) {
		self.transform = CGAffineTransform(translationX: CGFloat(direction == .horizontal ? 20.0 : 0), y: CGFloat(direction == .horizontal ? 0.0 : 20.0))

		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
			self.transform = CGAffineTransform.identity
		}, completion: completion)
	}
	
}
