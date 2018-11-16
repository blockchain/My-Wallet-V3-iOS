//
//  TransactionDetailCell.swift
//  PlatformUIKit
//
//  Created by AlexM on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public class TransactionDetailCell: UICollectionViewCell {
    
    // MARK: Private Static Properties
    
    static fileprivate let horizontalPadding: CGFloat = 32.0
    static fileprivate let verticalPadding: CGFloat = 32.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var subject: UILabel!
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    @IBOutlet fileprivate var statusImageView: UIImageView!
    
    public func configure(with model: CellModel) {
        guard case let .transactionDetail(payload) = model else { return }
        
        layer.cornerRadius = 4.0
        subject.text = payload.description
        descriptionLabel.text = payload.value
        subject.font = payload.bold ? TransactionDetailCell.mediumFont() : TransactionDetailCell.standardFont()
        descriptionLabel.font = payload.bold ? TransactionDetailCell.mediumFont() : TransactionDetailCell.standardFont()
        backgroundColor = payload.backgroundColor
        subject.textColor = payload.bold ? .darkGray : #colorLiteral(red: 0.64, green: 0.64, blue: 0.64, alpha: 1)
        statusImageView.alpha = payload.statusVisibility.defaultAlpha
        statusImageView.tintColor = payload.statusTintColor
    }
    
    public class func heightForProposedWidth(_ width: CGFloat, model: CellModel) -> CGFloat {
        guard case let .transactionDetail(payload) = model else { return 0.0 }
        let description = NSAttributedString(
            string: payload.description,
            attributes: [.font: standardFont()]
        )
        
        let value = NSAttributedString(
            string: payload.value,
            attributes: [.font: standardFont()]
        )
        
        let availableWidth = width - horizontalPadding - description.width
        let height = value.heightForWidth(width: availableWidth) + verticalPadding
        
        return height
    }
    
    // MARK: - Accessibility
    
    /// Implements initial cell accessibility property values.
    internal func applyAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
        shouldGroupAccessibilityChildren = false
    }
    
    fileprivate static func mediumFont() -> UIFont {
        let font = Font(
            .branded(.montserratMedium),
            size: .standard(.small(.h1))
        )
        return font.result
    }
    
    fileprivate static func standardFont() -> UIFont {
        let font = Font(
            .branded(.montserratRegular),
            size: .standard(.small(.h1))
        )
        return font.result
    }
}
