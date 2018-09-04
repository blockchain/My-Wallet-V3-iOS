//
//  ExchangeCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol ExchangeDependencies {
    var service: ExchangeHistoryAPI { get }
    var markets: ExchangeMarketsAPI { get }
    var inputs: ExchangeInputsAPI { get }
}

struct ExchangeServices: ExchangeDependencies {
    let service: ExchangeHistoryAPI
    let markets: ExchangeMarketsAPI
    let inputs: ExchangeInputsAPI

    init() {
        service = ExchangeService()
        markets = MarketsService()
        inputs = ExchangeInputsService()
    }
}

@objc class ExchangeCoordinator: NSObject, Coordinator {

    private enum ExchangeType {
        case homebrew
        case shapeshift
    }

    private(set) var user: KYCUser?

    static let shared = ExchangeCoordinator()

    // class function declared so that the ExchangeCoordinator singleton can be accessed from obj-C
    @objc class func sharedInstance() -> ExchangeCoordinator {
        return ExchangeCoordinator.shared
    }
    
    // MARK: Public Properties
    
    weak var exchangeOutput: ExchangeListOutput?

    private let walletManager: WalletManager

    private let walletService: WalletService
    private let dependencies: ExchangeDependencies = ExchangeServices()

    private var disposable: Disposable?
    
    private var exchangeListViewController: ExchangeListViewController?

    // MARK: - Navigation
    private var navigationController: BCNavigationController?
    private var exchangeViewController: PartnerExchangeListViewController?
    private var rootViewController: UIViewController?

    // MARK: - Entry Point

    func start() {
        if let theUser = user, theUser.status == .approved {
            showAppropriateExchange(); return
        }
        disposable = BlockchainDataRepository.shared.kycUser
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] in
                self.user = $0
                guard self.user?.status == .approved else {
                    KYCCoordinator.shared.start(); return
                }
                self.showAppropriateExchange()
                Logger.shared.debug("Got user with ID: \($0.personalDetails?.identifier ?? "")")
            }, onError: { error in
                Logger.shared.error("Failed to get user: \(error.localizedDescription)")
                AlertViewPresenter.shared.standardError(message: error.localizedDescription, title: "Error", in: self.rootViewController)
            })
    }

    private func showAppropriateExchange() {
        if WalletManager.shared.wallet.hasEthAccount() {
            let success = { [weak self] (isHomebrewAvailable: Bool) in
                if isHomebrewAvailable {
                    self?.showExchange(type: .homebrew)
                } else {
                    self?.showExchange(type: .shapeshift)
                }
            }
            let error = { (error: Error) in
                Logger.shared.error("Error checking if homebrew is available: \(error) - showing shapeshift")
                self.showExchange(type: .shapeshift)
            }
            checkForHomebrewAvailability(success: success, error: error)
        } else {
            if WalletManager.shared.wallet.needsSecondPassword() {
                AuthenticationCoordinator.shared.showPasswordConfirm(
                    withDisplayText: LocalizationConstants.Authentication.etherSecondPasswordPrompt,
                    headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                    validateSecondPassword: true
                ) { (secondPassword) in
                    WalletManager.shared.wallet.createEthAccount(forExchange: secondPassword)
                }
            } else {
                WalletManager.shared.wallet.createEthAccount(forExchange: nil)
            }
        }
    }

    private func checkForHomebrewAvailability(success: @escaping (Bool) -> Void, error: @escaping (Error) -> Void) {
        guard let countryCode = WalletManager.sharedInstance().wallet.countryCodeGuess() else {
            error(NetworkError.generic(message: "No country code found"))
            return
        }

        // Since individual exchange flows have to fetch their own data on initialization, the caller is left responsible for dismissing the busy view
        
        disposable = walletService.isCountryInHomebrewRegion(countryCode: countryCode)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: success, onError: error)
    }

    private func showExchange(type: ExchangeType) {
        switch type {
        case .homebrew:
            guard let viewController = rootViewController else {
                Logger.shared.error("View controller to present on is nil")
                return
            }
            let listViewController = ExchangeListViewController.make(with: dependencies, coordinator: self)
            navigationController = BCNavigationController(
                rootViewController: listViewController,
                title: LocalizationConstants.Exchange.navigationTitle
            )
            viewController.present(navigationController!, animated: true)
        default:
            guard let viewController = rootViewController else {
                Logger.shared.error("View controller to present on is nil")
                return
            }
            exchangeViewController = PartnerExchangeListViewController()
            let partnerNavigationController = BCNavigationController(
                rootViewController: exchangeViewController,
                title: LocalizationConstants.Exchange.navigationTitle
            )
            viewController.present(partnerNavigationController, animated: true)
        }
    }

    private func showCreateExchange(animated: Bool, type: ExchangeType) {
        switch type {
        case .homebrew:
            let exchangeCreateViewController = ExchangeCreateViewController.make(with: dependencies)
            if navigationController == nil {
                guard let viewController = rootViewController else {
                    Logger.shared.error("View controller to present on is nil")
                    return
                }
                navigationController = BCNavigationController(
                    rootViewController: exchangeCreateViewController,
                    title: LocalizationConstants.Exchange.navigationTitle
                )
                viewController.topMostViewController?.present(navigationController!, animated: animated)
            } else {
                navigationController?.pushViewController(exchangeCreateViewController, animated: animated)
            }
        default:
            // show shapeshift
            Logger.shared.debug("Not yet implemented")
        }
    }

    // MARK: - Event handling
    enum ExchangeCoordinatorEvent {
        case createHomebrewExchange(animated: Bool, viewController: UIViewController?)
        case createPartnerExchange(animated: Bool, viewController: UIViewController?)
    }

    func handle(event: ExchangeCoordinatorEvent) {
        switch event {
        case .createHomebrewExchange(let animated, let viewController):
            if viewController != nil {
                rootViewController = viewController
            }
            showCreateExchange(animated: animated, type: .homebrew)
        case .createPartnerExchange(let animated, let viewController):
            if viewController != nil {
                rootViewController = viewController
            }
            showCreateExchange(animated: animated, type: .homebrew)
        }
    }

    // MARK: - Services
    private let marketsService: MarketsService
    private let exchangeService: ExchangeService

    // MARK: - Lifecycle
    private init(
        walletManager: WalletManager = WalletManager.shared,
        walletService: WalletService = WalletService.shared,
        marketsService: MarketsService = MarketsService(),
        exchangeService: ExchangeService = ExchangeService()
    ) {
        self.walletManager = walletManager
        self.walletService = walletService
        self.marketsService = marketsService
        self.exchangeService = exchangeService
        super.init()
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}

// MARK: - Coordination
@objc extension ExchangeCoordinator {
    func start(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        start()
    }

    func reloadSymbols() {
        exchangeViewController?.reloadSymbols()
    }
}

extension ExchangeCoordinator {
    func subscribeToRates() {

    }
}
