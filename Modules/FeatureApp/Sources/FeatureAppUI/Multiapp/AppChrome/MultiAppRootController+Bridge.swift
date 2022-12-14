// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import FeatureInterestUI
import FeatureOnboardingUI
import FeaturePin
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

extension MultiAppRootController: LoggedInBridge {
    public func alert(_ content: AlertViewContent) {
//        alertViewPresenter.notify(content: content, in: topMostViewController ?? self)
    }

    public func presentPostSignUpOnboarding() {
        onboardingRouter.presentPostSignUpOnboarding(from: self)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { output in
                "\(output)".peek("🏄")
            })
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &bag)
    }

    public func presentPostSignInOnboarding() {
        onboardingRouter.presentPostSignInOnboarding(from: self)
            .handleEvents(receiveOutput: { output in
                "\(output)".peek("🏄")
            })
            .sink { [weak self] result in
                guard let self, self.presentedViewController != nil, result != .skipped else {
                    return
                }
                self.dismiss(animated: true)
            }
            .store(in: &bag)
    }

    public func toggleSideMenu() {
//        dismiss(animated: true) { [self] in
//            viewStore.send(.enter(into: .account, context: .none))
//        }
    }

    public func closeSideMenu() {
//        viewStore.send(.dismiss())
    }

    public func send(from account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .send(account, nil))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    public func send(from account: BlockchainAccount, target: TransactionTarget) {
        transactionsRouter.presentTransactionFlow(to: .send(account, target))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    public func sign(from account: BlockchainAccount, target: TransactionTarget) {
        transactionsRouter.presentTransactionFlow(
            to: .sign(
                sourceAccount: account,
                destination: target
            )
        )
        .sink { result in "\(result)".peek("🧾") }
        .store(in: &bag)
    }

    public func receive(into account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .receive(account as? CryptoAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    public func withdraw(from account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .withdraw(account as! FiatAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    public func deposit(into account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .deposit(account as! FiatAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    public func interestTransfer(into account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .interestTransfer(account as! CryptoInterestAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    public func interestWithdraw(from account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .interestWithdraw(account as! CryptoInterestAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    public func switchTabToDashboard() {
//        app.post(event: blockchain.ux.home.tab[blockchain.ux.user.portfolio].select)
    }

    public func switchToSend() {
        handleSendCrypto()
    }

    public func switchTabToSwap() {
        handleSwapCrypto(account: nil)
    }

    public func switchTabToReceive() {
        handleReceiveCrypto()
    }

    public func switchToActivity() {
//        app.post(event: blockchain.ux.home.tab[blockchain.ux.user.activity].select)
    }

    public func switchToActivity(for currencyType: CurrencyType) {
//        app.post(event: blockchain.ux.home.tab[blockchain.ux.user.activity].select)
    }

    public func showCashIdentityVerificationScreen() {
//        let presenter = CashIdentityVerificationPresenter()
//        let controller = CashIdentityVerificationViewController(presenter: presenter); do {
//            controller.transitioningDelegate = bottomSheetPresenter
//            controller.modalPresentationStyle = .custom
//            controller.isModalInPresentation = true
//        }
//        (topMostViewController ?? self).present(controller, animated: true, completion: nil)
    }

    public func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {
        let interactor = InteractiveFundsTransferDetailsInteractor(
            fiatCurrency: fiatCurrency
        )

        let webViewRouter = WebViewRouter(
            topMostViewControllerProvider: self
        )

        let presenter = FundsTransferDetailScreenPresenter(
            webViewRouter: webViewRouter,
            interactor: interactor,
            isOriginDeposit: isOriginDeposit
        )

        let viewController = DetailsScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)

        presenter.backRelay.publisher
            .sink { [weak navigationController] in
                navigationController?.dismiss(animated: true)
            }
            .store(in: &bag)

        topMostViewController?.present(navigationController, animated: true)
    }

    public func handleSwapCrypto(account: CryptoAccount?) {
        let transactionsRouter = transactionsRouter
        let onboardingRouter = onboardingRouter
        coincore.hasPositiveDisplayableBalanceAccounts(for: .crypto)
            .receive(on: DispatchQueue.main)
            .flatMap { positiveBalance -> AnyPublisher<TransactionFlowResult, Never> in
                if !positiveBalance {
                    guard let viewController = UIApplication.shared.topMostViewController else {
                        fatalError("Top most view controller cannot be nil")
                    }
                    return onboardingRouter
                        .presentRequiredCryptoBalanceView(from: viewController)
                        .map(TransactionFlowResult.init)
                        .eraseToAnyPublisher()
                } else {
                    return transactionsRouter.presentTransactionFlow(to: .swap(account))
                }
            }
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    public func handleSendCrypto() {
        transactionsRouter.presentTransactionFlow(to: .send(nil, nil))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    public func handleReceiveCrypto() {
        transactionsRouter.presentTransactionFlow(to: .receive(nil))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    public func handleSellCrypto(account: CryptoAccount?) {
        transactionsRouter.presentTransactionFlow(to: .sell(account))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    public func handleBuyCrypto(account: CryptoAccount?) {
        transactionsRouter.presentTransactionFlow(to: .buy(account))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    public func handleBuyCrypto() {
        handleBuyCrypto(currency: .bitcoin)
    }

    public func handleBuyCrypto(currency: CryptoCurrency) {
        guard app.currentMode != .pkw else {
            showBuyCryptoOpenTradingAccount()
            return
        }

        coincore
            .cryptoAccounts(for: currency, supporting: .buy, filter: .custodial)
            .receive(on: DispatchQueue.main)
            .map(\.first)
            .sink(to: My.handleBuyCrypto(account:), on: self)
            .store(in: &bag)
    }

    private func currentFiatAccount() -> AnyPublisher<FiatAccount, CoincoreError> {
        fiatCurrencyService.displayCurrencyPublisher
            .flatMap { [coincore] currency in
                coincore.allAccounts(filter: .allExcludingExchange)
                    .map { group in
                        group.accounts
                            .first { account in
                                account.currencyType.code == currency.code
                            }
                            .flatMap { account in
                                account as? FiatAccount
                            }
                    }
                    .first()
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public func handleDeposit() {
        currentFiatAccount()
            .sink(to: My.deposit(into:), on: self)
            .store(in: &bag)
    }

    public func handleWithdraw() {
        currentFiatAccount()
            .sink(to: My.withdraw(from:), on: self)
            .store(in: &bag)
    }

    public func handleRewards() {
        let interestAccountList = InterestAccountListHostingController(embeddedInNavigationView: true)
        interestAccountList.delegate = self
        topMostViewController?.present(
            interestAccountList,
            animated: true
        )
    }

    public func handleNFTAssetView() {
        topMostViewController?.present(
            AssetListHostingViewController(),
            animated: true
        )
    }

    public func handleSupport() {
        let isSupported = app.publisher(for: blockchain.app.configuration.customer.support.is.enabled, as: Bool.self)
            .prefix(1)
            .replaceError(with: false)
        Publishers.Zip(
            isSupported,
            eligibilityService.isEligiblePublisher
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] isSupported, isEligible in
            guard let self else { return }
            guard isEligible, isSupported else {
                return self.showLegacySupportAlert()
            }
            self.showCustomerChatSupportIfSupported()
        })
        .store(in: &bag)
    }

    private func showCustomerChatSupportIfSupported() {
        tiersService
            .fetchTiers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    switch completion {
                    case .failure(let error):
                        "\(error)".peek(as: .error, "‼️")
                        self.showLegacySupportAlert()
                    case .finished:
                        break
                    }
                },
                receiveValue: { [app] tiers in
                    guard tiers.isTier2Approved else {
                        self.showLegacySupportAlert()
                        return
                    }
                    app.post(event: blockchain.ux.customer.support.show.messenger)
                }
            )
            .store(in: &bag)
    }

    private func showLegacySupportAlert() {
//        alert(
//            .init(
//                title: String(format: LocalizationConstants.openArg, Constants.Support.url),
//                message: LocalizationConstants.youWillBeLeavingTheApp,
//                actions: [
//                    UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
//                        guard let url = URL(string: Constants.Support.url) else { return }
//                        UIApplication.shared.open(url)
//                    },
//                    UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
//                ]
//            )
//        )
    }

    private func showBuyCryptoOpenTradingAccount() {
//        let view = DefiBuyCryptoMessageView {
//            app.state.set(blockchain.app.mode, to: AppMode.trading.rawValue)
//        }
//        let viewController = UIHostingController(rootView: view)
//        viewController.transitioningDelegate = bottomSheetPresenter
//        viewController.modalPresentationStyle = .custom
//        present(viewController, animated: true, completion: nil)
    }

    public func startBackupFlow() {
        backupRouter.presentFlow()
    }

    public func showSettingsView() {
//        viewStore.send(.enter(into: .account, context: .none))
    }

    public func reload() {}

    public func presentKYCIfNeeded() {
        dismiss(animated: true) { [self] in
            kycRouter
                .presentKYCIfNeeded(
                    from: topMostViewController ?? self,
                    requiredTier: .tier2
                )
                .result()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] result in
                    switch result {
                    case .success(let kycRoutingResult):
                        guard case .completed = kycRoutingResult else { return }
                        // Upon successful KYC completion, present Interest
                        self?.handleRewards()
                    case .failure(let kycRoutingError):
                        Logger.shared.error(kycRoutingError)
                    }
                })
                .store(in: &bag)
        }
    }

    public func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency) {
        dismiss(animated: true) { [self] in
            handleBuyCrypto(currency: cryptoCurrency)
        }
    }

    public func enableBiometrics() {
        let logout = { [weak self] () -> Void in
            self?.global.send(.logout)
        }
        let flow = PinRouting.Flow.enableBiometrics(
            parent: UnretainedContentBox<UIViewController>(topMostViewController ?? self),
            logoutRouting: logout
        )
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.global.send(.wallet(.authenticateForBiometrics(password: password)))
            self?.pinRouter = nil
        }
        pinRouter?.execute()
    }

    public func changePin() {
        let logout = { [weak self] () -> Void in
            self?.global.send(.logout)
        }
        let flow = PinRouting.Flow.change(
            parent: UnretainedContentBox<UIViewController>(topMostViewController ?? self),
            logoutRouting: logout
        )
        pinRouter = PinRouter(flow: flow) { [weak self] _ in
            self?.pinRouter = nil
        }
        pinRouter?.execute()
    }

    public func showQRCodeScanner() {
//        dismiss(animated: true) { [self] in
//            viewStore.send(.enter(into: .QR, context: .none))
//        }
    }

    public func logout() {
        alert(
            .init(
                title: LocalizationConstants.SideMenu.logout,
                message: LocalizationConstants.SideMenu.logoutConfirm,
                actions: [
                    UIAlertAction(
                        title: LocalizationConstants.okString,
                        style: .default
                    ) { [weak self] _ in
//                        self?.viewStore.send(.dismiss())
                        self?.global.send(.logout)
                    },
                    UIAlertAction(
                        title: LocalizationConstants.cancel,
                        style: .cancel
                    )
                ]
            )
        )
    }

    public func logoutAndForgetWallet() {
//        viewStore.send(.dismiss())
//        global.send(.deleteWallet)
    }

    public func handleSecureChannel() {
//        public func show() {
//            viewStore.send(.enter(into: .QR, context: .none))
//        }
//        if viewStore.route == nil {
//            show()
//        } else {
//            viewStore.send(.dismiss())
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { show() }
//        }
    }
}
