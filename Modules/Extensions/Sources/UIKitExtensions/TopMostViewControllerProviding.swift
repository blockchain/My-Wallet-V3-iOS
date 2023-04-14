// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)

import UIKit

/// A provider protocol for top most view controller
public protocol TopMostViewControllerProviding: AnyObject {
    var topMostViewController: UIViewController? { get }
}

// MARK: - UIApplication

extension UIApplication: TopMostViewControllerProviding {
    public var topMostViewController: UIViewController? {
        windows.first(where: \.isKeyWindow)?.topMostViewController
    }
}

// MARK: - UIWindow

extension UIWindow: TopMostViewControllerProviding {
    public var topMostViewController: UIViewController? {
        rootViewController?.topMostViewController
    }
}

// MARK: - UIViewController

extension UIViewController: TopMostViewControllerProviding {

    /// Returns the top-most visibly presented UIViewController in this UIViewController's hierarchy
    @objc
    public var topMostViewController: UIViewController? {
        topViewController(of: self)
    }

    /// Returns the top-most visibly presented UIViewController in this UIViewController's hierarchy
    @objc
    public var currentTopMostViewController: UIViewController {
        topViewController(of: self, allowBeingDismissed: true)
    }
}

private func topViewController(of viewController: UIViewController, allowBeingDismissed: Bool = false) -> UIViewController {

    if
        let navigationController = viewController as? UINavigationController,
        let visibleViewController = navigationController.visibleViewController,
        allowBeingDismissed || !visibleViewController.isBeingDismissed
    {
        return topViewController(of: visibleViewController)
    }

    if
        let tabBarController = viewController as? UITabBarController,
        let selectedViewController = tabBarController.selectedViewController
    {
        return topViewController(of: selectedViewController)
    }

    if
        let presented = viewController.presentedViewController,
        allowBeingDismissed || !presented.isBeingDismissed
    {
        return topViewController(of: presented)
    }

    return viewController
}

#endif
