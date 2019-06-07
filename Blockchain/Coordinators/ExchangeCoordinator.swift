//
//  ExchangeCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import StellarKit
import PlatformKit

enum ExchangeCoordinatorEvent {
    case createPartnerExchange(country: KYCCountry, animated: Bool)
    case confirmExchange(orderTransaction: OrderTransaction, conversion: Conversion)
    case sentTransaction(orderTransaction: OrderTransaction, conversion: Conversion)
    case showTradeDetails(trade: ExchangeTradeModel)
}

protocol ExchangeCoordinatorAPI {
    func handle(event: ExchangeCoordinatorEvent)
    
    /// This is used to determine if the user should see `Swap` when
    /// they tap on `Swap` in the tab bar. If the user cannot `Swap`
    /// They should see a CTA screen asking them to go through KYC.
    /// They may also see a screen that shows that they are not permitted
    /// to use `Swap` in their country. (TBD)
    func canSwap() -> Single<Bool>
}

@objc class ExchangeCoordinator: NSObject, Coordinator, ExchangeCoordinatorAPI {

    private enum ExchangeType {
        case homebrew
        case shapeshift
    }

    static let shared = ExchangeCoordinator()

    // class function declared so that the ExchangeCoordinator singleton can be accessed from obj-C
    @objc class func sharedInstance() -> ExchangeCoordinator {
        return ExchangeCoordinator.shared
    }
    
    // MARK: - Private Properties

    private let walletManager: WalletManager
    private var disposable: Disposable?

    // MARK: - Navigation
    private var navigationController: ExchangeNavigationController?
    private var exchangeViewController: PartnerExchangeListViewController?
    private var rootViewController: UIViewController?

    // MARK: - Entry Point

    func start() {
        disposable = canSwap()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] result in
                guard let this = self else { return }
                switch result {
                case true:
                    this.showAppropriateExchange()
                case false:
                    this.routeToTiers()
                }
            }, onError: { [weak self] error in
                guard let this = self else { return }
                AlertViewPresenter.shared.standardError(
                    message: this.errorMessage(for: error),
                    title: LocalizationConstants.Errors.error,
                    in: this.rootViewController
                )
                Logger.shared.error("Failed to get user: \(error.localizedDescription)")
            })
    }
    
    func canSwap() -> Single<Bool> {
        let user = BlockchainDataRepository.shared.nabuUser
            .take(1)
            .asSingle()
        let tiers = BlockchainDataRepository.shared.tiers
            .take(1)
            .asSingle()
        return Single.create(subscribe: { [unowned self] observer -> Disposable in
            self.disposable = Single.zip(user, tiers)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { payload in
                    let tiersResponse = payload.1
                    let approved = tiersResponse.userTiers.contains(where: {
                        return $0.tier != .tier0 && $0.state == .verified
                    })
                    guard approved == true else {
                        observer(.success(false))
                        return
                    }
                    observer(.success(true))
                }, onError: { error in
                    observer(.error(error))
                    Logger.shared.error("Failed to get user: \(error.localizedDescription)")
                })
            return Disposables.create()
        })
    }
    
    /// Note: `initXlmAccountIfNeeded` and `createEthAccountForExchange` are now public
    /// as we now create the `ExchangeCreateViewController` in `ExchangeContainerViewController`
    /// and this screen needs to be able to create XLM accounts and/or Ethereum accounts should
    /// the user not have one.
    func initXlmAccountIfNeeded(completion: @escaping (() -> ())) {
        disposable = xlmAccountRepository.initializeMetadataMaybe()
            .flatMap({ [unowned self] _ in
                return self.stellarAccountService.currentStellarAccount(fromCache: true)
            })
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion()
            }, onError: { error in
                completion()
                Logger.shared.error("Failed to fetch XLM account.")
            })
    }
    
    func createEthAccountForExchange() {
        if walletManager.wallet.needsSecondPassword() {
            AuthenticationCoordinator.shared.showPasswordConfirm(
                withDisplayText: LocalizationConstants.Authentication.etherSecondPasswordPrompt,
                headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                validateSecondPassword: true,
                confirmHandler: { (secondPassword) in
                    self.walletManager.wallet.createEthAccount(forExchange: secondPassword)
            }
            )
        } else {
            walletManager.wallet.createEthAccount(forExchange: nil)
        }
    }
    
    private func routeToTiers() {
        guard let viewController = rootViewController else {
            Logger.shared.error("View controller to present on is nil")
            return
        }
        disposable = KYCTiersViewController.routeToTiers(
            fromViewController: viewController
        )
    }

    // TICKET: IOS-1168 - Complete error handling TODOs throughout the KYC
    private func errorMessage(for error: Error) -> String {
        guard let serverError = error as? HTTPRequestServerError,
            case let .badStatusCode(_, badStatusCodeError) = serverError,
            let nabuError = badStatusCodeError as? NabuNetworkError else {
                return error.localizedDescription
        }
        switch (nabuError.type, nabuError.code) {
        case (.conflict, .userRegisteredAlready):
            return LocalizationConstants.KYC.emailAddressAlreadyInUse
        default:
            return error.localizedDescription
        }
    }

    private func showAppropriateExchange() {
        initXlmAccountIfNeeded { [unowned self] in
            if !self.walletManager.wallet.hasEthAccount() {
                self.createEthAccountForExchange()
            } else {
                self.showExchange(type: .homebrew)
            }
        }
    }

    private func showExchange(type: ExchangeType, country: KYCCountry? = nil) {
        switch type {
        case .homebrew:
            guard let viewController = rootViewController else {
                Logger.shared.error("View controller to present on is nil")
                return
            }
            let listViewController = ExchangeListViewController.make(with: ExchangeServices())
            navigationController = ExchangeNavigationController(
                rootViewController: listViewController,
                title: LocalizationConstants.Swap.swap
            )
            viewController.present(navigationController!, animated: true)
        case .shapeshift:
            guard let viewController = rootViewController else {
                Logger.shared.error("View controller to present on is nil")
                return
            }
            exchangeViewController = PartnerExchangeListViewController.create(withCountryCode: country?.code)
            let partnerNavigationController = ExchangeNavigationController(
                rootViewController: exchangeViewController,
                title: LocalizationConstants.Swap.swap
            )
            viewController.present(partnerNavigationController, animated: true)
        }
    }

    private func showCreateExchange(animated: Bool, type: ExchangeType, country: KYCCountry? = nil) {
        switch type {
        case .homebrew:
            let exchangeCreateViewController = ExchangeCreateViewController.makeFromStoryboard()
            if navigationController == nil {
                guard let viewController = rootViewController else {
                    Logger.shared.error("View controller to present on is nil")
                    return
                }
                navigationController = ExchangeNavigationController(
                    rootViewController: exchangeCreateViewController,
                    title: LocalizationConstants.Exchange.navigationTitle
                )
                viewController.topMostViewController?.present(navigationController!, animated: animated)
            } else {
                navigationController?.pushViewController(exchangeCreateViewController, animated: animated)
            }
        case .shapeshift:
            showExchange(type: .shapeshift, country: country)
        }
    }

    private func showConfirmExchange(orderTransaction: OrderTransaction, conversion: Conversion) {
        guard let navigationController = navigationController else {
            Logger.shared.error("No navigation controller found")
            return
        }
        let model = ExchangeDetailPageModel(type: .confirm(orderTransaction, conversion))
        let confirmController = ExchangeDetailViewController.make(with: model, dependencies: ExchangeServices())
        navigationController.pushViewController(confirmController, animated: true)
    }
    
    private func showLockedExchange(orderTransaction: OrderTransaction, conversion: Conversion) {
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.error("No navigation controller found")
            return
        }
        let model = ExchangeDetailPageModel(type: .locked(orderTransaction, conversion))
        let controller = ExchangeDetailViewController.make(with: model, dependencies: ExchangeServices())
        let navController = BCNavigationController(rootViewController: controller)
        navController.modalTransitionStyle = .coverVertical
        root.present(navController, animated: true, completion: nil)
    }

    private func showTradeDetails(trade: ExchangeTradeModel) {
        let model = ExchangeDetailPageModel(type: .overview(trade))
        let detailViewController = ExchangeDetailViewController.make(
            with: model,
            dependencies: ExchangeServices()
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func handle(event: ExchangeCoordinatorEvent) {
        switch event {
        case .createPartnerExchange(let country, let animated):
            showCreateExchange(animated: animated, type: .shapeshift, country: country)
        case .confirmExchange(let orderTransaction, let conversion):
            showConfirmExchange(orderTransaction: orderTransaction, conversion: conversion)
        case .sentTransaction(orderTransaction: let transaction, conversion: let conversion):
            showLockedExchange(orderTransaction: transaction, conversion: conversion)
        case .showTradeDetails(let trade):
            showTradeDetails(trade: trade)
        }
    }

    // MARK: - Services
    private let exchangeService: ExchangeService
    private let stellarAccountService: StellarAccountAPI
    private let xlmAccountRepository: StellarWalletAccountRepository

    // MARK: - Lifecycle
    private init(
        walletManager: WalletManager = WalletManager.shared,
        exchangeService: ExchangeService = ExchangeService(),
        stellarAccountService: StellarAccountAPI = XLMServiceProvider.shared.services.accounts,
        xlmAccountRepository: StellarWalletAccountRepository = XLMServiceProvider.shared.services.repository
    ) {
        self.walletManager = walletManager
        self.exchangeService = exchangeService
        self.stellarAccountService = stellarAccountService
        self.xlmAccountRepository = xlmAccountRepository
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
}

extension ExchangeCoordinator {
    func subscribeToRates() {

    }
}
