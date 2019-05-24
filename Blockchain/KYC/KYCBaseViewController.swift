//
//  KYCBaseViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import SafariServices
import PlatformUIKit
import PlatformKit

class KYCBaseViewController: UIViewController, KYCCoordinatorDelegate, KYCOnboardingNavigationControllerDelegate {

    var coordinator: KYCCoordinator!
    var pageType: KYCPageType = .welcome

    class func make(with coordinator: KYCCoordinator) -> KYCBaseViewController {
        assertionFailure("Should be implemented by subclasses")
        return KYCBaseViewController()
    }

    func apply(model: KYCPageModel) {
        Logger.shared.debug("Should be overriden to do something with KYCPageModel.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TICKET: IOS-1236 - Refactor KYCBaseViewController NavigationBarItem Titles
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupBarButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBarButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator.delegate = self
        coordinator.handle(event: .pageWillAppear(pageType))
    }

    override func viewWillDisappear(_ animated: Bool) {
        coordinator.delegate = nil
        super.viewWillDisappear(animated)
    }
    
    // MARK: Private Functions
    
    fileprivate func setupBarButtonItem() {
        guard let navController = navigationController as? KYCOnboardingNavigationController else { return }
        navController.onboardingDelegate = self
        navController.setupBarButtonItem()
    }
    
    fileprivate func presentNeedSomeHelpAlert() {
        let confirm = AlertAction(style: .confirm(LocalizationConstants.KYC.readNow))
        let cancel = AlertAction(style: .default(LocalizationConstants.KYC.contactSupport))
        let model = AlertModel(
            headline: LocalizationConstants.KYC.needSomeHelp,
            body: LocalizationConstants.KYC.helpGuides,
            actions: [confirm, cancel]
        )
        let alert = AlertView.make(with: model) { [weak self] action in
            guard let this = self else { return }
            guard let endpoint = URL(string: "https://blockchain.zendesk.com/") else { return }
            switch action.style {
            case .confirm:
                guard let url = URL.endpoint(
                    endpoint,
                    pathComponents: ["hc", "en-us", "categories", "360001135512-Identity-Verification"],
                    queryParameters: nil
                    ) else { return }
                let controller = SFSafariViewController(url: url)
                this.present(controller, animated: true, completion: nil)
            case .default:
                guard let url = URL.endpoint(
                    endpoint,
                    pathComponents: ["hc", "en-us", "requests", "new"],
                    queryParameters: ["ticket_form_id" : "360000186571"]
                    ) else { return }
                let controller = SFSafariViewController(url: url)
                this.present(controller, animated: true, completion: nil)
            case .dismiss:
                break
            }
        }
        alert.show()
    }
    
    func navControllerCTAType() -> NavigationCTA {
        guard let navController = navigationController as? KYCOnboardingNavigationController else { return .none }
        return navController.viewControllers.count == 1 ? .dismiss : .help
    }
    
    func navControllerRightBarButtonTapped(_ navController: KYCOnboardingNavigationController) {
        switch navControllerCTAType() {
        case .none:
            break
        case .dismiss:
            coordinator.stop()
        case .help:
            presentNeedSomeHelpAlert()
        }
    }
}
