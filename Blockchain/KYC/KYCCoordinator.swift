//
//  KYCCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

enum KYCEvent {

    /// When a particular screen appears, we need to
    /// look at the `KYCUser` object and determine if
    /// there is data there for pre-populate the screen with.
    case pageWillAppear(KYCPageType)

    /// This will push on the next page in the KYC flow.
    case nextPageFromPageType(KYCPageType, KYCPagePayload?)

    /// Event emitted when the provided page type emits an error
    case failurePageForPageType(KYCPageType, KYCPageError)

    // TODO:
    /// Should the user go back in the KYC flow, we need to
    /// prepopulate the screens with the data they already entered.
    /// We may need another event type for this and hook into
    /// `viewWillDisappear`.
}

protocol KYCCoordinatorDelegate: class {
    func apply(model: KYCPageModel)
}

/// Coordinates the KYC flow. This component can be used to start a new KYC flow, or if
/// the user drops off mid-KYC and decides to continue through it again, the coordinator
/// will handle recovering where they left off.
@objc class KYCCoordinator: NSObject, Coordinator {

    // MARK: - Public Properties

    weak var delegate: KYCCoordinatorDelegate?

    static let shared = KYCCoordinator()

    @objc class func sharedInstance() -> KYCCoordinator {
        return KYCCoordinator.shared
    }

    // MARK: - Private Properties

    private(set) var user: KYCUser?

    private(set) var country: KYCCountry?

    fileprivate var navController: KYCOnboardingNavigationController!

    private let pageFactory = KYCPageViewFactory()

    private var disposable: Disposable?

    private override init() { /* Disallow initializing from outside objects */ }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: Public

    func start() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        start(from: rootViewController)
    }

    @objc func start(from viewController: UIViewController) {
        if user == nil {
            disposable = BlockchainDataRepository.shared.kycUser
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [unowned self] in
                    self.user = $0
                    Logger.shared.debug("Got user with ID: \($0.personalDetails?.identifier ?? "")")
                }, onError: { error in
                    Logger.shared.error("Failed to get user: \(error.localizedDescription)")
                })
        }
        guard let welcomeViewController = pageFactory.createFrom(
            pageType: .welcome,
            in: self
        ) as? KYCWelcomeController else { return }
        navController = presentInNavigationController(welcomeViewController, in: viewController)
    }

    func handle(event: KYCEvent) {
        switch event {
        case .pageWillAppear(let type):
            handlePageWillAppear(for: type)
        case .failurePageForPageType(_, let error):
            handleFailurePage(for: error)
        case .nextPageFromPageType(let type, let payload):
            handlePayloadFromPageType(type, payload)
            guard let nextPage = type.nextPage(for: self.user) else { return }
            let controller = pageFactory.createFrom(
                pageType: nextPage,
                in: self,
                payload: payload
            )
            navController.pushViewController(controller, animated: true)
        }
    }

    func presentAccountStatusView(for status: KYCAccountStatus, in viewController: UIViewController) {
        let accountStatusViewController = KYCInformationController.make(with: self)
        accountStatusViewController.viewModel = KYCInformationViewModel.create(for: status)
        accountStatusViewController.viewConfig = KYCInformationViewConfig.create(for: status)
        accountStatusViewController.primaryButtonAction = { viewController in
            switch status {
            case .approved:
                viewController.dismiss(animated: true) {
                    ExchangeCoordinator.shared.start()
                }
            case .pending:
                PushNotificationManager.shared.requestAuthorization()
            case .failed, .expired, .none:
                // Confirm with design that this is how we should handle this
                URL(string: Constants.Url.blockchainSupport)?.launch()
            }
        }
        presentInNavigationController(accountStatusViewController, in: viewController)
    }

    // MARK: Private Methods

    private func handlePayloadFromPageType(_ pageType: KYCPageType, _ payload: KYCPagePayload?) {
        guard let payload = payload else { return }
        switch payload {
        case .countrySelected(let country):
            self.country = country
        case .phoneNumberUpdated:
            // Not handled here
            return
        }
    }

    private func handleFailurePage(for error: KYCPageError) {
        switch error {
        case .countryNotSupported(let country):
            let informationViewController = KYCInformationController.make(with: self)
            informationViewController.viewModel = KYCInformationViewModel.createForUnsupportedCountry(country)
            informationViewController.viewConfig = KYCInformationViewConfig(
                titleColor: UIColor.gray5,
                isPrimaryButtonEnabled: true
            )
            informationViewController.primaryButtonAction = { viewController in
                viewController.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
            presentInNavigationController(informationViewController, in: navController)
        }
    }

    private func handlePageWillAppear(for type: KYCPageType) {
        switch type {
        case .welcome,
             .country,
             .confirmPhone,
             .accountStatus,
             .applicationComplete:
            break
        case .profile:
            guard let current = user else { return }
            delegate?.apply(model: .personalDetails(current))
        case .address:
            guard let current = user else { return }
            guard let country = country else { return }
            delegate?.apply(model: .address(current, country))
        case .enterPhone:
            guard let current = user else { return }
            delegate?.apply(model: .phone(current))
        case .verifyIdentity:
            guard let country = country else { return }
            delegate?.apply(model: .verifyIdentity(country))
        }
    }

    @discardableResult private func presentInNavigationController(
        _ viewController: UIViewController,
        in presentingViewController: UIViewController
    ) -> KYCOnboardingNavigationController {
        let navController = KYCOnboardingNavigationController.make()
        navController.pushViewController(viewController, animated: false)
        navController.modalTransitionStyle = .coverVertical
        presentingViewController.present(navController, animated: true)
        return navController
    }

    private func pageTypeForUser() -> KYCPageType {
        guard let currentUser = user else { return .welcome }
        guard currentUser.personalDetails != nil else { return .welcome }

        if currentUser.address != nil {
            if let mobile = currentUser.mobile {
                switch mobile.verified {
                case true:
                    return .verifyIdentity
                case false:
                    return .enterPhone
                }
            }
            return .address
        }

        return .address
    }
}
