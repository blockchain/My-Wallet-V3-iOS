// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

public protocol DepositRootRouting: Routing {
    /// Routes to the `Select a Funding Method` screen
    func routeToDepositLanding()

    /// Routes to the TransactonFlow with a given `FiatAccount`
    func routeToDeposit(target: FiatAccount, sourceAccount: LinkedBankAccount?)

    /// Routes to the TransactonFlow with a given `FiatAccount`
    /// The user already has at least one linked bank.
    /// Does not execute dismissal of top most screen (Link Bank Flow)
    func startDeposit(target: FiatAccount, sourceAccount: LinkedBankAccount?)

    /// Routes to the wire details flow
    func routeToWireInstructions(currency: FiatCurrency)

    /// Routes to the wire details flow.
    /// Does not execute dismissal of top most screen (Payment Method Selector)
    func startWithWireInstructions(currency: FiatCurrency)

    /// Routes to the `Link a Bank Account` flow.
    /// Does not execute dismissal of top most screen (Payment Method Selector)
    func startWithLinkABank()

    /// Routes to the `Link a Bank Account` flow
    func routeToLinkABank()

    /// Exits the bank linking flow
    func dismissBankLinkingFlow()

    /// Exits the wire instruction flow
    func dismissWireInstructionFlow()

    /// Exits the payment method selection flow
    func dismissPaymentMethodFlow()

    /// Exits the TransactonFlow
    func dismissTransactionFlow()

    /// Starts the deposit flow. This is available as the `DepositRootRIB`
    /// does not own a view and we do not want to expose the entire `DepositRootRouter`
    /// but rather only `DepositRootRouting`
    func start()
}

extension DepositRootRouting where Self: RIBs.Router<DepositRootInteractable> {
    func start() {
        load()
    }
}

protocol DepositRootListener: ViewListener {}

final class DepositRootInteractor: Interactor, DepositRootInteractable, DepositRootListener {

    weak var router: DepositRootRouting?
    weak var listener: DepositRootListener?

    // MARK: - Private Properties

    private var paymentMethodTypes: Single<[PaymentMethodPayloadType]> {
        Single
            .just(targetAccount.fiatCurrency)
            .flatMap { [linkedBanksFactory] fiatCurrency -> Single<[PaymentMethodType]> in
                linkedBanksFactory.bankPaymentMethods(for: fiatCurrency).asSingle()
            }
            .map { $0.map(\.method) }
            .map { $0.map(\.rawType) }
    }

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let linkedBanksFactory: LinkedBanksFactoryAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let targetAccount: FiatAccount
    private let featureFlagsService: FeatureFlagsServiceAPI

    init(
        targetAccount: FiatAccount,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        linkedBanksFactory: LinkedBanksFactoryAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.targetAccount = targetAccount
        self.analyticsRecorder = analyticsRecorder
        self.linkedBanksFactory = linkedBanksFactory
        self.fiatCurrencyService = fiatCurrencyService
        self.featureFlagsService = featureFlagsService
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        Single.zip(
            linkedBanksFactory.linkedBanks,
            paymentMethodTypes,
            .just(targetAccount.fiatCurrency),
            featureFlagsService
                .isEnabled(.openBanking)
                .asSingle()
        )
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onSuccess: { [weak self] values in
            guard let self else { return }
            let (linkedBanks, paymentMethodTypes, fiatCurrency, openBanking) = values
            // An array of linked bank accounts that can be used for Deposit
            let filteredLinkedBanks = linkedBanks.filter { linkedBank in
                linkedBank.fiatCurrency == fiatCurrency
                    && linkedBank.paymentType == .bankTransfer
                    && (linkedBank.partner != .yapily || openBanking)
            }

            if filteredLinkedBanks.isEmpty {
                handleNoLinkedBanks(
                    paymentMethodTypes,
                    fiatCurrency: fiatCurrency
                )
            } else {
                // If you want the TxFlow to go straight to the
                // `Enter Amount` screen, pass in a `sourceAccount`.
                // However, if you do this, the user will not be able to
                // return to the prior screen to change their source.
                router?.startDeposit(
                    target: targetAccount,
                    sourceAccount: nil
                )
            }
        })
        .disposeOnDeactivate(interactor: self)
    }

    func bankLinkingComplete() {
        linkedBanksFactory
            .linkedBanks
            .compactMap(\.first)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] linkedBankAccount in
                guard let self else { return }
                router?.routeToDeposit(
                    target: targetAccount,
                    sourceAccount: linkedBankAccount
                )
            })
            .disposeOnDeactivate(interactor: self)
    }

    func bankLinkingClosed(isInteractive: Bool) {
        router?.dismissBankLinkingFlow()
    }

    func closePaymentMethodScreen() {
        router?.dismissPaymentMethodFlow()
    }

    func routeToWireTransfer() {
        fiatCurrencyService
            .tradingCurrency
            .asSingle()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] fiatCurrency in
                self?.router?.routeToWireInstructions(currency: fiatCurrency)
            })
            .disposeOnDeactivate(interactor: self)
    }

    func routeToLinkedBanks() {
        router?.routeToLinkABank()
    }

    func dismissTransactionFlow() {
        router?.dismissTransactionFlow()
    }

    func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        unimplemented()
    }

    func dismissAddNewBankAccount() {
        router?.dismissWireInstructionFlow()
    }

    // MARK: - Private Functions

    private func handleNoLinkedBanks(_ paymentMethodTypes: [PaymentMethodPayloadType], fiatCurrency: FiatCurrency) {
        if paymentMethodTypes.contains(.bankAccount), paymentMethodTypes.contains(.bankTransfer) {
            router?.routeToDepositLanding()
        } else if paymentMethodTypes.contains(.bankTransfer) {
            router?.startWithLinkABank()
        } else if paymentMethodTypes.contains(.bankAccount) {
            router?.startWithWireInstructions(currency: fiatCurrency)
        } else {
            // TODO: Show that deposit is not supported
        }
    }
}
