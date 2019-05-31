//
//  BaseCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class BaseCell: UICollectionViewCell {
    // TODO: Bring `ReusableView` into `PlatformUIKit`
    public static var identifier: String { return String(describing: self) }
    
    public func configure(_ model: ContainerModel) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    public func configure(_ model: CellModel) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    public class func heightForProposedWidth(_ width: CGFloat, model: CellModel) -> CGFloat {
        return 0.0 // Cells should override this method.
    }
    
    public class func heightForProposedWidth(_ width: CGFloat, containerModel: ContainerModel) -> CGFloat {
        return 0.0 // Containers should override this method.
    }
    
    public class func sectionTitleFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(24.0))
        return font.result
    }
    
    public class func sectionTitleColor() -> UIColor {
        return UIColor.black
    }
    
    // MARK: - Accessibility
    
    /// Implements initial cell accessibility property values.
    internal func applyAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .none
        shouldGroupAccessibilityChildren = false
    }
}
