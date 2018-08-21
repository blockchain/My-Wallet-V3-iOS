//
//  UIView+Center.swift
//  Blockchain
//
//  Created by kevinwu on 8/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension UIView {
    func centerInSuperview() {
        guard let parentView = self.superview else { return }
        self.center = CGPoint(x: parentView.bounds.width/2, y: parentView.bounds.height/2)
    }

    func centerHorizontallyInSuperview() {
        guard let parentView = self.superview else { return }
        self.center = CGPoint(x: parentView.bounds.width/2, y: self.center.y)
    }

    func centerVerticallyInSuperview() {
        guard let parentView = self.superview else { return }
        self.center = CGPoint(x: self.center.x, y: parentView.bounds.height/2)
    }
}
