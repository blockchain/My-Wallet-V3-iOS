// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension UIView {
    public func applyRadius(_ radius: CGFloat, to corners: UIRectCorner) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    public func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
