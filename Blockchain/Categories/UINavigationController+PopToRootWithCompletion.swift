//
//  UINavigationController+PopToRootWithCompletion.swift
//  Blockchain
//
//  Created by Kevin Wu on 12/22/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension UINavigationController {
    func popToRootViewControllerWithHandler(_ completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: true)
        CATransaction.commit()
    }
}
