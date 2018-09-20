//
//  UILabel.swift
//  Blockchain
//
//  Created by kevinwu on 9/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension UILabel {
    func showTemporaryTextColor(color: UIColor, originalColor: UIColor) {
        // Originally this was written with a reference to self.textColor.
        // Passing in originalColor is likely needed due to the possibility of this being called
        // by a tap gesture many times in a short period, during which self.textColor could at that point
        // be the temporary color at the time this method is called next.
        // As a result, referencing self.textColor poses the risk of permanently changing self.textColor to the
        // new color instead of temporarily.
        UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: {
            // Animate quickly to the temporary color
            self.textColor = color
        }, completion: { _ in
            // Animate slowly to the original color
            UIView.transition(with: self, duration: 0.8, options: .transitionCrossDissolve, animations: {
                self.textColor = originalColor
            })
        })
    }
}
