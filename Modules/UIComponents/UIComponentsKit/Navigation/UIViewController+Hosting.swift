// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import UIKit

extension UIViewController {

    /// Embeds a `SwiftUI.View` inside a `UIViewController`. The embeeded view takes over the entire controller's view.
    /// - Parameter view: The `SwiftUI.View` to embed in the controller.
    public func embed(@ViewBuilder _ view: () -> some View) {
        let hostViewController = UIHostingController(rootView: view())
        addChild(hostViewController)
        self.view.addSubview(hostViewController.view)
        hostViewController.view.constraint(edgesTo: self.view)
        hostViewController.didMove(toParent: self)
    }

    /// Embeds a `SwiftUI.View` inside a `UIViewController`. The embeeded view takes over the entire controller's view.
    /// - Parameter view: The `SwiftUI.View` to embed in the controller.
    public func embed(_ view: some View) {
        let hostViewController = UIHostingController(rootView: view)
        addChild(hostViewController)
        self.view.addSubview(hostViewController.view)
        hostViewController.view.constraint(edgesTo: self.view)
        hostViewController.didMove(toParent: self)
    }

    /// Allows any `UIViewController` to present a `UIViewController` with an embedded `SwiftUI.View`, optionally wrapped in a `UINavigationController`
    /// - Parameters:
    ///   - view: The `SwiftUI.View` to be presented.
    ///   - inNavigationController: If `true` the `UIViewController` hosting the `view` is wrapped within a `UINavigationController`.
    @discardableResult public func present(
        _ view: some View,
        inNavigationController: Bool = false,
        modalPresentationStyle: UIModalPresentationStyle = .automatic
    ) -> UIViewController {
        let hostViewController = UIHostingController(rootView: view)
        hostViewController.isModalInPresentation = true
        hostViewController.modalPresentationStyle = modalPresentationStyle
        let destination: UIViewController
        if inNavigationController {
            let navigationController = UINavigationController(rootViewController: hostViewController)
            navigationController.navigationBar.tintColor = .linkableText
            destination = navigationController
        } else {
            destination = hostViewController
        }
        enter(into: destination)
        return destination
    }
}
