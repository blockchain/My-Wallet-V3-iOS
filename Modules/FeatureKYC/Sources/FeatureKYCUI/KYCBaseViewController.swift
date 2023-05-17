// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import DIKit
import FeatureKYCDomain
import Localization
import PlatformKit
import PlatformUIKit
import SafariServices
import ToolKit

class KYCBaseViewController: UIViewController, KYCRouterDelegate, KYCOnboardingNavigationControllerDelegate {

    private let webViewService: WebViewServiceAPI = resolve()
    var router: KYCRouter!
    var pageType: KYCPageType = .welcome

    class func make(with coordinator: KYCRouter) -> KYCBaseViewController {
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
        view.backgroundColor = UIColor.semantic.light
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBarButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        router.delegate = self
        router.handle(event: .pageWillAppear(pageType))
    }

    override func viewWillDisappear(_ animated: Bool) {
        router.delegate = nil
        super.viewWillDisappear(animated)
    }

    // MARK: Private Functions

    fileprivate func setupBarButtonItem() {
        guard let navController = navigationController as? KYCOnboardingNavigationController else { return }
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.semantic.light
        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.compactAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
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
            switch action.style {
            case .confirm:
                let url = "https://blockchain.zendesk.com/hc/en-us/categories/360001135512-Identity-Verification"
                this.webViewService.openSafari(url: url, from: this)
            case .default:
                let url = "https://blockchain.zendesk.com/hc/en-us/requests/new?ticket_form_id=360000186571"
                this.webViewService.openSafari(url: url, from: this)
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
            onNavControllerRightBarButtonWillDismiss()
            router.stop()
        case .help:
            presentNeedSomeHelpAlert()
        case .skip:
            onNavControllerRightBarButtonSkip()
        }
    }

    // MARK: - Optionally override

    func onNavControllerRightBarButtonWillDismiss() {}
    func onNavControllerRightBarButtonSkip() {}
}
