// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)

import Foundation
import UIKit

extension UIWindow {
    /// Ensure code is running on main thread and sets the rootViewController
    public func setRootViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            self?.rootViewController = viewController
        }
    }
}

#endif
