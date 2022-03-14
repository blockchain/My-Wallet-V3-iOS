//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureInterestUI
import FeatureOnboardingUI
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import ToolKit
import UIComponentsKit

extension RootViewController: LoggedInBridge {

    func alert(_ content: AlertViewContent) {
        alertViewPresenter.notify(content: content, in: topMostViewController ?? self)
    }

    func presentPostSignUpOnboarding() {
        onboardingRouter.presentPostSignUpOnboarding(from: self)
            .handleEvents(receiveOutput: { output in
                "\(output)".peek("🏄")
            })
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &bag)
    }

    func presentPostSignInOnboarding() {
        onboardingRouter.presentPostSignInOnboarding(from: self)
            .handleEvents(receiveOutput: { output in
                "\(output)".peek("🏄")
            })
            .sink { [weak self] _ in
                guard let self = self, self.presentedViewController != nil else {
                    return
                }
                self.dismiss(animated: true)
            }
            .store(in: &bag)
    }

    func toggleSideMenu() {
        dismiss(animated: true) { [self] in
            viewStore.send(.enter(into: .account, context: .none))
        }
    }

    func closeSideMenu() {
        viewStore.send(.dismiss())
    }

    func send(from account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .send(account, nil))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    func send(from account: BlockchainAccount, target: TransactionTarget) {
        transactionsRouter.presentTransactionFlow(to: .send(account, target))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    func sign(from account: BlockchainAccount, target: TransactionTarget) {
        transactionsRouter.presentTransactionFlow(
            to: .sign(
                sourceAccount: account,
                destination: target
            )
        )
        .sink { result in "\(result)".peek("🧾") }
        .store(in: &bag)
    }

    func receive(into account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .receive(account as? CryptoAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    func withdraw(from account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .withdraw(account as! FiatAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    func deposit(into account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .deposit(account as! FiatAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    func interestTransfer(into account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .interestTransfer(account as! CryptoInterestAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    func interestWithdraw(from account: BlockchainAccount) {
        transactionsRouter.presentTransactionFlow(to: .interestWithdraw(account as! CryptoInterestAccount))
            .sink { result in "\(result)".peek("🧾") }
            .store(in: &bag)
    }

    func switchTabToDashboard() {
        dismiss(animated: true) { [self] in
            viewStore.send(.tab(.home))
        }
    }

    func switchToSend() {
        handleSendCrypto()
    }

    func switchTabToSwap() {
        handleSwapCrypto(account: nil)
    }

    func switchTabToReceive() {
        handleReceiveCrypto()
    }

    func switchToActivity() {
        dismiss(animated: true) { [self] in
            viewStore.send(.tab(.activity))
        }
    }

    func switchToActivity(for currencyType: CurrencyType) {
        dismiss(animated: true) { [self] in
            viewStore.send(.tab(.activity))
        }
    }

    func showCashIdentityVerificationScreen() {
        let presenter = CashIdentityVerificationPresenter()
        let controller = CashIdentityVerificationViewController(presenter: presenter); do {
            controller.transitioningDelegate = bottomSheetPresenter
            controller.modalPresentationStyle = .custom
            controller.isModalInPresentation = true
        }
        (topMostViewController ?? self).present(controller, animated: true, completion: nil)
    }

    func showInterestDashboardAnnouncementScreen(isKYCVerfied: Bool) {
        var presenter: InterestDashboardAnnouncementPresenting
        let router = InterestDashboardAnnouncementRouter(
            navigationRouter: NavigationRouter()
        )
        if isKYCVerfied {
            presenter = InterestDashboardAnnouncementScreenPresenter(
                router: router
            )
        } else {
            presenter = InterestIdentityVerificationScreenPresenter(
                router: router
            )
        }
        let controller = InterestDashboardAnnouncementViewController(presenter: presenter); do {
            controller.transitioningDelegate = bottomSheetPresenter
            controller.modalPresentationStyle = .custom
            controller.isModalInPresentation = true
        }
        (topMostViewController ?? self).present(controller, animated: true, completion: nil)
    }

    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {

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

    func handleSwapCrypto(account: CryptoAccount?) {
        let transactionsRouter = transactionsRouter
        let onboardingRouter = onboardingRouter
        userStateService
            .userState
            .first()
            .receive(on: DispatchQueue.main)
            .flatMap { result -> AnyPublisher<TransactionFlowResult, Never> in
                // if we successfully got a user state object and that shows the user has a crypto balance <= 0, show the empty state
                if case .success(let userState) = result, !userState.balanceData.hasAnyCryptoBalance {
                    guard let viewController = UIApplication.shared.topMostViewController else {
                        fatalError("Top most view controller cannot be nil")
                    }
                    return onboardingRouter
                        .presentRequiredCryptoBalanceView(from: viewController)
                        .map(TransactionFlowResult.init)
                        .eraseToAnyPublisher()
                }
                // if instead we didn't get a user state, or the user state shows the user has a crypto balance > 0, just navigate to swap
                return transactionsRouter.presentTransactionFlow(to: .swap(account))
            }
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleSendCrypto() {
        transactionsRouter.presentTransactionFlow(to: .send(nil, nil))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleReceiveCrypto() {
        transactionsRouter.presentTransactionFlow(to: .receive(nil))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleSellCrypto(account: CryptoAccount?) {
        transactionsRouter.presentTransactionFlow(to: .sell(account))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleBuyCrypto(account: CryptoAccount?) {
        transactionsRouter.presentTransactionFlow(to: .buy(account))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleBuyCrypto() {
        handleBuyCrypto(currency: .bitcoin)
    }

    func handleBuyCrypto(currency: CryptoCurrency) {
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
                coincore.allAccounts
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

    func handleDeposit() {
        currentFiatAccount()
            .sink(to: My.deposit(into:), on: self)
            .store(in: &bag)
    }

    func handleWithdraw() {
        currentFiatAccount()
            .sink(to: My.withdraw(from:), on: self)
            .store(in: &bag)
    }

    func handleRewards() {
        let interestAccountList = InterestAccountListHostingController()
        interestAccountList.delegate = self
        topMostViewController?.present(
            interestAccountList,
            animated: true
        )
    }

    func handleExchange() {
        ExchangeCoordinator.shared.start(from: self)
    }

    func handleSupport() {
        Publishers.Zip(
            featureFlagService.isEnabled(.remote(.customerSupportChat)),
            eligibilityService.isEligiblePublisher
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] isSupported, isEligible in
            guard let self = self else { return }
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
                    guard let self = self else { return }
                    switch completion {
                    case .failure(let error):
                        "\(error)".peek(as: .error, "‼️")
                        self.showLegacySupportAlert()
                    case .finished:
                        break
                    }
                },
                receiveValue: { [customerSupportChatRouter] tiers in
                    guard tiers.isTier2Approved else {
                        self.showLegacySupportAlert()
                        return
                    }
                    customerSupportChatRouter.start()
                }
            )
            .store(in: &bag)
    }

    private func showLegacySupportAlert() {
        alert(
            .init(
                title: String(format: LocalizationConstants.openArg, Constants.Url.blockchainSupport),
                message: LocalizationConstants.youWillBeLeavingTheApp,
                actions: [
                    UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
                        guard let url = URL(string: Constants.Url.blockchainSupport) else { return }
                        UIApplication.shared.open(url)
                    },
                    UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
                ]
            )
        )
    }

    func startBackupFlow() {
        backupRouter.start()
    }

    func showSettingsView() {
        viewStore.send(.enter(into: .account, context: .none))
    }

    func reload() {
        accountsAndAddressesNavigationController?.reload()
    }

    func presentKYCIfNeeded() {
        dismiss(animated: true) { [self] in
            kycRouter
                .presentKYCIfNeeded(
                    from: topMostViewController ?? self,
                    requiredTier: .tier2
                )
                .mapToResult()
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

    func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency) {
        dismiss(animated: true) { [self] in
            handleBuyCrypto(currency: cryptoCurrency)
        }
    }

    func enableBiometrics() {
        let logout = { [weak self] () -> Void in
            self?.send(.logout)
        }
        let flow = PinRouting.Flow.enableBiometrics(
            parent: UnretainedContentBox<UIViewController>(topMostViewController ?? self),
            logoutRouting: logout
        )
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.send(.wallet(.authenticateForBiometrics(password: password)))
            self?.pinRouter = nil
        }
        pinRouter?.execute()
    }

    func changePin() {
        let logout = { [weak self] () -> Void in
            self?.send(.logout)
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

    func showQRCodeScanner() {
        dismiss(animated: true) { [self] in
            viewStore.send(.enter(into: .QR, context: .none))
        }
    }

    func logout() {
        alert(
            .init(
                title: LocalizationConstants.SideMenu.logout,
                message: LocalizationConstants.SideMenu.logoutConfirm,
                actions: [
                    UIAlertAction(
                        title: LocalizationConstants.okString,
                        style: .default
                    ) { [weak self] _ in
                        self?.viewStore.send(.dismiss())
                        self?.send(.logout)
                    },
                    UIAlertAction(
                        title: LocalizationConstants.cancel,
                        style: .cancel
                    )
                ]
            )
        )
    }

    func handleAccountsAndAddresses() {
        let storyboard = UIStoryboard(name: "AccountsAndAddresses", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "AccountsAndAddressesNavigationController"
        ) as! AccountsAndAddressesNavigationController
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .coverVertical
        viewController.navigationBar.tintColor = .lightGray
        viewController.reload()
        (topMostViewController ?? self).present(viewController, animated: true)
        accountsAndAddressesNavigationController = viewController
    }

    func handleAirdrops() {
        airdropRouter.presentAirdropCenterScreen()
    }

    func handleSecureChannel() {
        func show() {
            viewStore.send(.enter(into: .QR, context: .none))
        }
        if viewStore.route == nil {
            show()
        } else {
            viewStore.send(.dismiss())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { show() }
        }
    }
}
