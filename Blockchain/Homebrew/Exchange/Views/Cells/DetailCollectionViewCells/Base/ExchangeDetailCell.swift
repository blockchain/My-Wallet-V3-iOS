//
//  ExchangeDetailTableViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeDetailCell: UICollectionViewCell {
    
    func configure(with model: ExchangeCellModel) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    class func heightForProposedWidth(_ width: CGFloat, model: ExchangeCellModel) -> CGFloat {
        // Cells should override this method.
        return 0.0
    }
    
    // MARK: - Accessibility
    
    /// Implements initial cell accessibility property values.
    internal func applyAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
        shouldGroupAccessibilityChildren = false
    }
}
