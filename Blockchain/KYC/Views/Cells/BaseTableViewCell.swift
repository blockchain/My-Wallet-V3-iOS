//
//  BaseTableViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    func configure(with model: CellModel) {
        assertionFailure("Should be implemented by subclasses")
    }

    class func heightForProposedWidth(_ width: CGFloat, model: CellModel) -> CGFloat {
        return 0.0 // Cells should override this method.
    }

    // MARK: - Accessibility

    /// Implements initial cell accessibility property values.
    internal func applyAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
        shouldGroupAccessibilityChildren = false
    }
}
