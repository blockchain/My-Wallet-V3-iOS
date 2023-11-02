// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)

import SwiftExtensions
import UIKit

/// A provider protocol for top most view controller
public protocol TopMostViewControllerProviding: AnyObject {
    var topMostViewController: UIViewController? { get }
    func findTopViewController(allowBeingDismissed: Bool) -> UIViewController
}

// MARK: - UIApplication

extension UIApplication: TopMostViewControllerProviding {

    public var topMostViewController: UIViewController? {
        connectedScenes.filter(UIWindowScene.self)
            .compactMap { scene in scene.windows.first(where: \.isKeyWindow) }
            .first?
            .topMostViewController
    }

    public func findTopViewController(allowBeingDismissed: Bool = false) -> UIViewController {
        connectedScenes.filter(UIWindowScene.self)
            .compactMap { scene in scene.windows.first(where: \.isKeyWindow) }
            .first!
            .findTopViewController(allowBeingDismissed: allowBeingDismissed)
    }
}

// MARK: - UIWindow

extension UIWindow: TopMostViewControllerProviding {

    public var topMostViewController: UIViewController? {
        rootViewController?.topMostViewController
    }

    public func findTopViewController(allowBeingDismissed: Bool = false) -> UIViewController {
        guard let rootViewController else { fatalError("UIWindow expected to have a rootViewController") }
        return UIKitExtensions.findTopViewController(of: rootViewController, allowBeingDismissed: allowBeingDismissed)
    }
}

extension UIViewController {
    enum ViewControllerError: LocalizedError {
        case unableToFindTopViewController

        var errorDescription: String? {
            switch self {
            case .unableToFindTopViewController:
                "Unable to find top view controller, hit max depth limit"
            }
        }
    }

    private static var maxDepth = 10

    public func enter(into viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, retries: Int = 0) {
        if NSClassFromString("XCTestCase") != nil {
            return present(viewController, animated: animated, completion: completion)
        }
        if isBeingDismissed || presentedViewController?.isBeingDismissed == true {
            return DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [presentingViewController] in
                (presentingViewController ?? UIApplication.shared.topMostViewController ?? self)
                    .enter(into: viewController, animated: animated, completion: completion)
            }
        }
        if view.window.isNotNil {
            present(viewController, animated: animated, completion: completion)
        } else if retries < UIViewController.maxDepth {
            UIApplication.shared.topMostViewController!.enter(into: viewController, animated: animated, completion: completion, retries: retries + 1)
        } else {
            NotificationCenter.default.post(
                name: NSNotification.Name("error.notification"),
                object: self,
                userInfo: [
                    "error": ViewControllerError.unableToFindTopViewController
                ]
            )
        }
    }
}

// MARK: - UIViewController

extension UIViewController: TopMostViewControllerProviding {

    /// Returns the top-most visibly presented UIViewController in this UIViewController's hierarchy
    @objc
    public var topMostViewController: UIViewController? {
        UIKitExtensions.findTopViewController(of: self, allowBeingDismissed: true)
    }

    public func findTopViewController(allowBeingDismissed: Bool) -> UIViewController {
        UIKitExtensions.findTopViewController(of: self, allowBeingDismissed: allowBeingDismissed)
    }
}

public func findTopViewController(of viewController: UIViewController, allowBeingDismissed: Bool = false) -> UIViewController {

    if
        let navigationController = viewController as? UINavigationController,
        let visibleViewController = navigationController.visibleViewController,
        allowBeingDismissed || !visibleViewController.isBeingDismissed
    {
        return findTopViewController(of: visibleViewController, allowBeingDismissed: allowBeingDismissed)
    }

    if
        let tabBarController = viewController as? UITabBarController,
        let selectedViewController = tabBarController.selectedViewController
    {
        return findTopViewController(of: selectedViewController, allowBeingDismissed: allowBeingDismissed)
    }

    if
        let presented = viewController.presentedViewController,
        allowBeingDismissed || !presented.isBeingDismissed
    {
        return findTopViewController(of: presented, allowBeingDismissed: allowBeingDismissed)
    }

    return viewController
}

#endif
