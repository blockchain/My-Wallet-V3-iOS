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
    var service: ExchangeService { get }
}

struct ExchangeServices: ExchangeDependencies {
    let service: ExchangeService
    
    init() {
        service = ExchangeService()
    }
}

@objc class ExchangeCoordinator: NSObject, Coordinator {

    private enum ExchangeType {
        case homebrew
        case shapeshift
    }

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
    private var exchangeViewController: ExchangeOverviewViewController?
    private var rootViewController: UIViewController?

    private init(
        walletManager: WalletManager = WalletManager.shared,
        walletService: WalletService = WalletService.shared
    ) {
        self.walletManager = walletManager
        self.walletService = walletService
        super.init()
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func start() {
        if WalletManager.shared.wallet.hasEthAccount() {
            let success = { [weak self] (isHomebrewAvailable: Bool) in
                if !isHomebrewAvailable {
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
//        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.Exchange.loading)

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
            let listViewController = ExchangeListViewController.make(with: dependencies)
            let navigationController = BCNavigationController(
                rootViewController: listViewController,
                title: LocalizationConstants.Exchange.navigationTitle
            )
            viewController.present(navigationController, animated: true)
        default:
            guard let viewController = rootViewController else {
                Logger.shared.error("View controller to present on is nil")
                return
            }
            exchangeViewController = ExchangeOverviewViewController()
            let navigationController = BCNavigationController(
                rootViewController: exchangeViewController,
                title: LocalizationConstants.Exchange.navigationTitle
            )
            viewController.present(navigationController, animated: true)
        }
    }
}

@objc extension ExchangeCoordinator {
    func start(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        start()
    }

    func reloadSymbols() {
        exchangeViewController?.reloadSymbols()
    }
}
