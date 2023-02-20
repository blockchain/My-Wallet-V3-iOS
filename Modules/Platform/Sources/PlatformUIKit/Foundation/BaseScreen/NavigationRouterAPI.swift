// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import RxRelay
import ToolKit
import UIComponentsKit

/// Emits a command to return to the previous state
public protocol RoutingPreviousStateEmitterAPI: AnyObject {
    /// Move to the previous state
    var previousRelay: PublishRelay<Void> { get }
}

/// Emits a command to move forward to the next state
public protocol RoutingNextStateEmitterAPI: AnyObject {
    /// Move to the next state
    var nextRelay: PublishRelay<Void> { get }
}

public protocol NavigationRouterAPI: AnyObject {
    var navigationControllerAPI: NavigationControllerAPI? { get set }
    var topMostViewControllerProvider: TopMostViewControllerProviding! { get }

    func present(viewController: UIViewController, using presentationType: PresentationType)
    func present(viewController: UIViewController)

    func dismiss(completion: (() -> Void)?)
    func dismiss(using presentationType: PresentationType)
    func dismiss()

    func pop(animated: Bool)
}

public enum RoutingType {
    case modal
    case embed(inside: NavigationControllerAPI)
}

public class NavigationRouter: NavigationRouterAPI {

    public weak var navigationControllerAPI: NavigationControllerAPI?
    public weak var topMostViewControllerProvider: TopMostViewControllerProviding!

    public var defaultPresentationType: PresentationType {
        if navigationControllerAPI != nil {
            return .navigationFromCurrent
        } else {
            return .modalOverTopMost
        }
    }

    public var defaultDismissalType: PresentationType? {
        guard let navigationControllerAPI else {
            return nil
        }
        if navigationControllerAPI.viewControllersCount == 1 {
            return .modalOverTopMost
        } else {
            return .navigationFromCurrent
        }
    }

    public init(topMostViewControllerProvider: TopMostViewControllerProviding = resolve()) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }

    public func present(viewController: UIViewController) {
        present(viewController: viewController, using: defaultPresentationType)
    }

    private func presentModal(viewController: UIViewController, in parent: ViewControllerAPI) {
        let navigationController: UINavigationController
        if let navController = viewController as? UINavigationController {
            navigationController = navController
        } else {
            navigationController = UINavigationController(rootViewController: viewController)
        }
        DispatchQueue.main.async { [weak self] in
            parent.present(navigationController, animated: true, completion: nil)
            self?.navigationControllerAPI = navigationController
        }
    }

    public func present(viewController: UIViewController, using presentationType: PresentationType) {
        switch presentationType {
        case .modal(from: let parentViewController):
            presentModal(viewController: viewController, in: parentViewController)
        case .navigation(from: let originViewController):
            if BuildFlag.isInternal {
                if originViewController.navigationControllerAPI == nil {
                    fatalError("When presenting a \(type(of: viewController)), originViewController \(type(of: originViewController)), originViewController.navigationControllerAPI was nil.")
                }
            }
            originViewController.navigationControllerAPI?.pushViewController(viewController, animated: true)
        case .navigationFromCurrent:
            if BuildFlag.isInternal {
                if navigationControllerAPI == nil {
                    fatalError("When presenting a \(type(of: viewController)), navigationControllerAPI was nil.")
                }
            }
            navigationControllerAPI?.pushViewController(viewController, animated: true)
        case .modalOverTopMost:
            if let parentViewController = topMostViewControllerProvider.topMostViewController {
                presentModal(viewController: viewController, in: parentViewController)
            }
        }
    }

    public func dismiss(completion: (() -> Void)?) {
        navigationControllerAPI?.dismiss(animated: true, completion: completion)
    }

    public func dismiss() {
        dismiss(using: defaultPresentationType)
    }

    public func dismiss(using presentationType: PresentationType) {
        switch presentationType {
        case .modal, .modalOverTopMost:
            navigationControllerAPI?.dismiss(animated: true, completion: nil)
        case .navigation, .navigationFromCurrent:
            navigationControllerAPI?.popViewController(animated: true)
        }
    }

    public func pop(animated: Bool) {
        navigationControllerAPI?.popViewController(animated: true)
    }
}
