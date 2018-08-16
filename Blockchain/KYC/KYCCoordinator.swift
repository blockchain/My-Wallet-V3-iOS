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
    case nextPageFromPageType(KYCPageType)

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

    fileprivate var navController: KYCOnboardingNavigationController!

    fileprivate var user: KYCUser?

    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: Public

    weak var delegate: KYCCoordinatorDelegate?

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
        guard let welcomeViewController = screenFor(pageType: .welcome) as? KYCWelcomeController else { return }
        presentInNavigationController(welcomeViewController, in: viewController)
    }

    func handle(event: KYCEvent) {
        switch event {
        case .pageWillAppear(let type):
            switch type {
            case .welcome,
                 .country,
                 .confirmPhone,
                 .verifyIdentity,
                 .accountStatus:
                break
            case .profile:
                guard let current = user else { return }
                guard let details = current.personalDetails else { return }
                delegate?.apply(model: .personalDetails(details))
            case .address:
                guard let current = user else { return }
                guard let address = current.address else { return }
                delegate?.apply(model: .address(address))

            case .enterPhone:
                guard let current = user else { return }
                guard let mobile = current.mobile else { return }
                delegate?.apply(model: .phone(mobile))
            }
        case .nextPageFromPageType(let type):
            guard let nextPage = type.next else { return }
            let controller = screenFor(pageType: nextPage)
            navController.pushViewController(controller, animated: true)
        }
    }

    func presentAccountStatusView(for status: KYCAccountStatus, in viewController: UIViewController) {
        let accountStatusViewController = KYCAccountStatusController.make(with: self)
        accountStatusViewController.accountStatus = status
        accountStatusViewController.primaryButtonAction = { viewController in
            switch viewController.accountStatus {
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

    private func presentInNavigationController(_ viewController: UIViewController, in presentingViewController: UIViewController) {
        navController = KYCOnboardingNavigationController.make()
        navController.pushViewController(viewController, animated: false)
        navController.modalTransitionStyle = .coverVertical
        presentingViewController.present(navController, animated: true)
    }

    private func screenFor(pageType: KYCPageType) -> KYCBaseViewController {
        switch pageType {
        case .welcome:
            return KYCWelcomeController.make(with: self)
        case .country:
            return KYCCountrySelectionController.make(with: self)
        case .profile:
            return KYCPersonalDetailsController.make(with: self)
        case .address:
            return KYCAddressController.make(with: self)
        case .enterPhone:
            return KYCEnterPhoneNumberController.make(with: self)
        case .confirmPhone:
            return KYCConfirmPhoneNumberController.make(with: self)
        case .verifyIdentity:
            return KYCVerifyIdentityController.make(with: self)
        case .accountStatus:
            return KYCAccountStatusController.make(with: self)
        }
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
