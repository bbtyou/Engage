//
//  UIView+Extensions
//  Adapt SEG
//
//  Created by Charles Imperato on 8/5/17.
//  Copyright © 2017 Adapt. All rights reserved.
//

import UIKit

public extension UIView {

    /// Add `subview` so that it completely covers the view.
    ///
    /// - parameter subview: the subview to add
    func addCoveringSubview(_ subview: UIView) -> Void {
        subview.prepareForAddByRemovingFromSuperviewAndCleaningUpConstraints()
        addSubview(subview)

        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        subview.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        subview.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    /// If the view has `siblingSubview` as a subview, then `subview` is inserted **above** `siblingSubview`.
    /// If `siblingSubview` is not a subview, then `subview` is added.
    ///
    /// - parameter subview: the subview to insert
    /// - parameter siblingSubview: the relative subview to based the insert or add on
    func insertSubview(_ subview: UIView, maybeAboveSubview siblingSubview: UIView) -> Void {
        if siblingSubview.superview == self {
            insertSubview(subview, aboveSubview: siblingSubview)
        } else {
            addSubview(subview)
        }
    }

    /// If the view has `siblingSubview` as a subview, then `subview` is inserted **below** `siblingSubview`.
    /// If `siblingSubview` is not a subview, then `subview` is added.
    ///
    /// - parameter subview: the subview to insert
    /// - parameter siblingSubview: the relative subview to based the insert or add on
    func insertSubview(_ subview: UIView, maybeBelowSubview siblingSubview: UIView) -> Void {
        if siblingSubview.superview == self {
            insertSubview(subview, belowSubview: siblingSubview)
        } else {
            addSubview(subview)
        }
    }

    /// Prepare a view to be added as a subivew. After the view has been added, it must have contraints set
    /// to its new superview.
    func prepareForAddByRemovingFromSuperviewAndCleaningUpConstraints() -> Void {
        removeFromSuperview() // Removes all external constraints
        removeConstraints(constraints.filter { $0.secondItem == nil }) // Removes all self constraints
        translatesAutoresizingMaskIntoConstraints = false // Disable struts and springs
    }


}

// MARK: - Shakeable

extension UIView: Shakeable {}
