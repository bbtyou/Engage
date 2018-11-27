//
//  UIScrollView+Extensions.swift
//  Adapt SEG
//
//  Created by Charles Imperato on 12/11/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var isScrollable: Bool {
        return self.contentSize.height > self.bounds.size.height || self.contentSize.width > self.bounds.size.width
    }
    
    enum Direction {
        case horizontal
        case vertical
    }
    
    func animateScrollViewBound(_ direction: Direction) {
        if self.isScrollable == true {
            let animationOnePoint: CGPoint
            let animationTwpPoint: CGPoint
            
            switch direction {
                case .horizontal:
                    animationOnePoint = CGPoint.init(x: 50.0, y: 0.0)
                    animationTwpPoint = CGPoint.init(x: -10.0, y: 0.0)
                
                case .vertical:
                    animationOnePoint = CGPoint.init(x: 0.0, y: 50.0)
                    animationTwpPoint = CGPoint.init(x: 0.0, y: -10.0)
            }
            
            UIView.animate(withDuration: 0.25, delay: 0.25, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.setContentOffset(animationOnePoint, animated: false)
            }, completion: { (finished) in
                if finished == true {
                    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn, .curveEaseOut, .allowUserInteraction], animations: {
                        self.setContentOffset(animationTwpPoint, animated: false)
                    }, completion: { (finished) in
                        self.setContentOffset(.zero, animated: true)
                    })
                }
            })
        }
    }
}
