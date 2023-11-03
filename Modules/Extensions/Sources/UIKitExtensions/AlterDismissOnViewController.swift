#if os(iOS)

import SwiftUI

private var dismissViewControllerKey: Bool = false

extension UIViewController {
    public static let controllerDidDismiss = Notification.Name(rawValue: "controller.did.dismiss")
}

public func alterDismissOnViewControllers() {
    if !dismissViewControllerKey {
        dismissViewControllerKey = true

        let original = #selector(UIViewController.dismiss(animated:completion:))
        let swizzled = #selector(UIViewController.swizzled_dismiss(animated:completion:))
        if let originalMethod = class_getInstanceMethod(UIViewController.self, original),
           let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzled)
        {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension UIViewController {
    @objc
    func swizzled_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        swizzled_dismiss(animated: flag) {
            NotificationCenter.default.post(.init(name: UIViewController.controllerDidDismiss))
            completion?()
        }
    }
}

#endif
