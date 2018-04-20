//
//  UIViewController.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension UIViewController {

    /// Returns the top-most visibly presented UIViewController in this UIViewController's hierarchy
    @objc var topMostViewController: UIViewController? {
        return presentedViewController?.topMostViewController ?? self
    }
}

extension UINavigationController {
    override var topMostViewController: UIViewController? {
        return visibleViewController ?? self
    }
}
