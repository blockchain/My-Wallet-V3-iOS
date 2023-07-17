// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

public protocol WithdrawRootRouting: Routing {
    /// Routes to the wire details flow.
    /// Does not execute dismissal of top most screen (Payment Method Selector)
    func startWithWireInstructions(currency: FiatCurrency)

    /// Routes to the wire details flow
    func routeToWireInstructions(currency: FiatCurrency)

    /// Routes to the `Link a Bank Account` flow.
    /// Does not execute dismissal of top most screen (Payment Method Selector)
    func startWithLinkABank()

    /// Routes to the `Link a Bank Account` flow
    func routeToLinkABank()

    /// Routes to the `Add a Bank Account` screen
    func routeToAddABank()

    /// Routes to the withdraw flow.
    /// The user already has at least one linked bank.
    /// Does not execute dismissal of top most screen (Link Bank Flow)
    func startWithdraw(sourceAccount: FiatAccount, destination: LinkedBankAccount?)

    /// Routes to the TransactonFlow with a given `FiatAccount`
    /// and a `LinkedBankAccount`
    func routeToWithdraw(sourceAccount: FiatAccount, destination: LinkedBankAccount?)

    /// Exits the bank linking flow
    func dismissBankLinkingFlow()

    /// Exits the TransactonFlow
    func dismissTransactionFlow()

    /// Exits the wire instruction flow
    func dismissWireInstructionFlow()

    /// Exits the payment method selection flow
    func dismissPaymentMethodFlow()

    /// Starts the withdraw flow. This is available as the `WithdrawRootRIB`
    /// does not own a view and we do not want to expose the entire `WithdrawRootRouter`
    /// but rather only `WithdrawRootRouting`
    func start()
}

extension WithdrawRootRouting where Self: RIBs.Router<WithdrawRootInteractable> {
    func start() {
        load()
    }
}

protocol WithdrawRootListener: ViewListener {}

public final class WithdrawRootInteractor: Interactor,
    WithdrawRootInteractable,
    WithdrawRootListener
{

    weak var router: WithdrawRootRouting?
    weak var listener: WithdrawRootListener?

    // MARK: - Private Properties

    private var paymentMethodTypes: Single<[PaymentMethodPayloadType]> {
        Single
            .just(sourceAccount.fiatCurrency)
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<[PaymentMethodType]> in
                self.linkedBanksFactory.bankPaymentMethods(for: fiatCurrency).asSingle()
            }
            .map { $0.map(\.method) }
            .map { $0.map(\.rawType) }
    }

    private let app: AppProtocol
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let linkedBanksFactory: LinkedBanksFactoryAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let sourceAccount: FiatAccount

    public init(
        sourceAccount: FiatAccount,
        app: AppProtocol = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        linkedBanksFactory: LinkedBanksFactoryAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.sourceAccount = sourceAccount
        self.app = app
        self.analyticsRecorder = analyticsRecorder
        self.linkedBanksFactory = linkedBanksFactory
        self.fiatCurrencyService = fiatCurrencyService
        super.init()
    }

    override public func didBecomeActive() {
        super.didBecomeActive()

        Single.zip(
            linkedBanksFactory.linkedBanks,
            paymentMethodTypes,
            .just(sourceAccount.fiatCurrency),
            isArgentinaLinkBankEnabled
        )
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onSuccess: { [weak self] values in
            guard let self else { return }
            let (linkedBanks, paymentMethodTypes, fiatCurrency, isArgentinaLinkBankEnabled) = values
            let filteredLinkedBanks = linkedBanks.filter { $0.fiatCurrency == fiatCurrency }
            let country: String? = try? app.state.get(blockchain.user.address.country.code)
            if filteredLinkedBanks.isEmpty, !isArgentinaLinkBankEnabled || country?.isArgentina == false {
                handleNoLinkedBanks(
                    paymentMethodTypes,
                    fiatCurrency: fiatCurrency
                )
            } else {
                // If you want the TxFlow to go straight to the
                // `Enter Amount` screen, pass in a `destination`.
                // However, if you do this, the user will not be able to
                // return to the prior screen to change the destination.
                router?.startWithdraw(
                    sourceAccount: sourceAccount,
                    destination: nil
                )
            }
        })
        .disposeOnDeactivate(interactor: self)
    }

    private var isArgentinaLinkBankEnabled: Single<Bool> {
        app.publisher(
            for: blockchain.app.configuration.argentinalinkbank.is.enabled,
            as: Bool.self
        )
        .map(\.value)
        .replaceNil(with: false)
        .asSingle()
    }

    func bankLinkingComplete() {
        linkedBanksFactory
            .linkedBanks
            .compactMap(\.first)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] linkedBankAccount in
                guard let self else { return }
                router?.routeToWithdraw(
                    sourceAccount: sourceAccount,
                    destination: linkedBankAccount
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

    func routeToLinkedBanks() {
        router?.routeToLinkABank()
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

    public func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        unimplemented()
    }

    public func dismissAddNewBankAccount() {
        router?.dismissWireInstructionFlow()
    }

    public func dismissTransactionFlow() {
        router?.dismissTransactionFlow()
    }

    // MARK: - Private Functions

    private func handleNoLinkedBanks(_ paymentMethodTypes: [PaymentMethodPayloadType], fiatCurrency: FiatCurrency) {
        if paymentMethodTypes.contains(.bankAccount), paymentMethodTypes.contains(.bankTransfer) {
            router?.routeToAddABank()
        } else if paymentMethodTypes.contains(.bankTransfer) {
            router?.startWithLinkABank()
        } else if paymentMethodTypes.contains(.bankAccount) {
            router?.startWithWireInstructions(currency: fiatCurrency)
        } else {
            // TODO: Show that withdraw is not supported
        }
    }
}
