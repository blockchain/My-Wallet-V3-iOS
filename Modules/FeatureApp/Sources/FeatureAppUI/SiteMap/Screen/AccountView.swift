//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsUI
import SwiftUI

// Needs to exist her because on SuperApp it will get deinit imediately causing issues.
private var navigationController: UINavigationController?

public struct AccountView: UIViewControllerRepresentable {

    let router: SettingsRouterAPI = resolve()

    private var _navController: UINavigationController {
        navigationController ?? UINavigationController()
    }

    public init() {
        navigationController = UINavigationController()
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = router.makeViewController()
        viewController.automaticallyApplyNavigationBarStyle = false
        viewController.navigationItem.backButtonDisplayMode = .minimal
        _navController.viewControllers = [viewController]
        _navController.modalPresentationStyle = .overFullScreen
        router.navigationRouter.navigationControllerAPI = navigationController
        return _navController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    public static func dismantleUIViewController(_ uiViewController: UINavigationController, coordinator: ()) {
        navigationController = nil
    }
}
