// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import Extensions
import FeatureCheckoutUI
import FeaturePlaidDomain
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import UIKit

protocol ConfirmationPageListener: AnyObject {
    func closeFlow()
    func checkoutDidTapBack()
}

protocol ConfirmationPageBuildable {
    func build(listener: ConfirmationPageListener) -> ViewableRouter<Interactable, ViewControllable>
}

final class ConfirmationPageBuilder: ConfirmationPageBuildable {
    private let transactionModel: TransactionModel
    private let action: AssetAction
    private let app: AppProtocol
    private let priceService: PriceServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    init(
        transactionModel: TransactionModel,
        action: AssetAction,
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        app: AppProtocol = DIKit.resolve()
    ) {
        self.transactionModel = transactionModel
        self.action = action
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.app = app
    }

    func build(listener: ConfirmationPageListener) -> ViewableRouter<Interactable, ViewControllable> {
        if let newCheckout { return newCheckout }
        let detailsPresenter = ConfirmationPageDetailsPresenter()
        let viewController = DetailsScreenViewController(presenter: detailsPresenter)
        let interactor = ConfirmationPageInteractor(presenter: detailsPresenter, transactionModel: transactionModel)
        interactor.listener = listener
        return ConfirmationPageRouter(interactor: interactor, viewController: viewController)
    }

    var newCheckout: ViewableRouter<Interactable, ViewControllable>? {

        guard app.remoteConfiguration.yes(
            if: blockchain.ux.transaction.checkout.is.enabled
        ) else { return nil }

        let viewController: UIViewController
        switch action {
        case .swap:
            viewController = buildSwapCheckout(for: transactionModel)
        case .buy:
            viewController = buildBuyCheckout(for: transactionModel)
        default:
            return nil
        }

        return ViewableRouter(
            interactor: Interactor(),
            viewController: viewController
        )
    }
}

// MARK: - Swap

extension ConfirmationPageBuilder {

    private func buildBuyCheckout(for transactionModel: TransactionModel) -> UIViewController {

        let publisher = transactionModel.state.publisher
            .ignoreFailure(setFailureType: Never.self)
            .compactMap { [app] state in
                app.remoteConfiguration.yes(if: blockchain.ux.transaction.checkout.quote.refresh.is.enabled)
                    ? state.buyCheckout
                    : state.pendingTransactionBuyCheckout
            }
            .removeDuplicates()

        let viewController = UIHostingController(
            rootView: BuyCheckoutView(publisher: publisher)
                .onAppear { transactionModel.process(action: .validateTransaction) }
                .navigationTitle(LocalizationConstants.Checkout.buyTitle)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: IconButton(
                        icon: .chevronLeft,
                        action: { [app] in
                            transactionModel.process(action: .returnToPreviousStep)
                            app.post(event: blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back)
                        }
                    )
                )
                .app(app)
        )
        viewController.title = " "
        viewController.navigationItem.leftBarButtonItem = .init(customView: UIView())
        viewController.isModalInPresentation = true

        app.on(blockchain.ux.transaction.checkout.confirmed).first().sink { _ in
            transactionModel.process(action: .executeTransaction)
        }
        .store(withLifetimeOf: viewController)

        return viewController
    }

    private func buildSwapCheckout(for transactionModel: TransactionModel) -> UIViewController {

        let publisher = transactionModel.state.publisher
            .ignoreFailure(setFailureType: Never.self)
            .removeDuplicates(by: { old, new in old.pendingTransaction == new.pendingTransaction })
            .task { [app, priceService] state -> SwapCheckout? in
                guard var checkout = state.swapCheckout else { return nil }
                do {
                    let currency: FiatCurrency = try await app.get(blockchain.user.currency.preferred.fiat.display.currency)

                    let sourceExchangeRate = try await priceService.price(of: checkout.from.cryptoValue.currency, in: currency)
                        .exchangeRatePair(checkout.from.cryptoValue.currency)
                        .await()

                    let sourceFeeExchangeRate = try await priceService.price(of: checkout.from.fee.currency, in: currency)
                        .exchangeRatePair(checkout.from.fee.currency)
                        .await()

                    let destinationExchangeRate = try await priceService.price(of: checkout.to.cryptoValue.currency, in: currency)
                        .exchangeRatePair(checkout.to.cryptoValue.currency)
                        .await()

                    checkout.from.exchangeRateToFiat = sourceExchangeRate
                    checkout.from.feeExchangeRateToFiat = sourceFeeExchangeRate

                    checkout.to.exchangeRateToFiat = destinationExchangeRate
                    checkout.to.feeExchangeRateToFiat = destinationExchangeRate

                    return checkout
                } catch {
                    return checkout
                }
            }
            .compactMap { $0 }

        let viewController = UIHostingController(
            rootView: SwapCheckoutView()
                .onAppear { transactionModel.process(action: .validateTransaction) }
                .environmentObject(SwapCheckoutView.Object(publisher: publisher.receive(on: DispatchQueue.main)))
                .navigationTitle(LocalizationConstants.Checkout.swapTitle)
                .navigationBarBackButtonHidden(true)
                .whiteNavigationBarStyle()
                .navigationBarItems(
                    leading: IconButton(
                        icon: .chevronLeft,
                        action: { [app] in
                            transactionModel.process(action: .returnToPreviousStep)
                            app.post(event: blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back)
                        }
                    )
                )
                .app(app)
        )
        viewController.title = " "
        viewController.navigationItem.leftBarButtonItem = .init(customView: UIView())
        viewController.isModalInPresentation = true

        app.on(blockchain.ux.transaction.checkout.confirmed).first().sink { _ in
            transactionModel.process(action: .executeTransaction)
        }
        .store(withLifetimeOf: viewController)

        return viewController
    }
}

extension Publisher where Output == PriceQuoteAtTime {

    func exchangeRatePair(_ currency: CryptoCurrency) -> AnyPublisher<MoneyValuePair, Failure> {
        map { MoneyValuePair(base: .one(currency: currency), exchangeRate: $0.moneyValue) }
            .eraseToAnyPublisher()
    }
}

extension PendingTransaction {
    var recurringBuyDetails: BuyCheckout.RecurringBuyDetails? {
        guard eligibleAndNextPaymentRecurringBuy != .oneTime else { return nil }
        return .init(
            frequency: eligibleAndNextPaymentRecurringBuy.frequency.description,
            description: eligibleAndNextPaymentRecurringBuy.date
        )
    }
}

extension TransactionState {

    var buyCheckout: BuyCheckout? {
        guard let source, let quote, let result = quote.result else { return nil }
        do {
            let fee = try quote.fee
            return try BuyCheckout(
                buyType: pendingTransaction?.recurringBuyFrequency == .once ? .simpleBuy : .recurringBuy,
                input: quote.amount,
                purchase: result,
                fee: .init(value: fee.withoutPromotion, promotion: fee.value),
                total: quote.amount.fiatValue.or(throw: "Expected fiat"),
                paymentMethod: source.checkoutPaymentMethod(),
                quoteExpiration: quote.date.expiresAt,
                recurringBuyDetails: pendingTransaction?.recurringBuyDetails,
                depositTerms: .init(
                    availableToTrade: quote.depositTerms?.formattedAvailableToTrade,
                    availableToWithdraw: quote.depositTerms?.formattedAvailableToWithdraw,
                    withdrawalLockInDays: quote.depositTerms?.formattedWithdrawalLockDays
                )
            )
        } catch {
            return nil
        }
    }

    var pendingTransactionBuyCheckout: BuyCheckout? {
        guard let pendingTransaction, let source else { return nil }
        do {
            let value = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.BuyCryptoValue.self).first.or(throw: "No value confirmation")
            let purchase = try (pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Purchase.self).first?.purchase).or(throw: "No purchase confirmation")
            let exchangeRate = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.BuyExchangeRateValue.self).first.or(throw: "No exchangeRate")
            let paymentMethod = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.BuyPaymentMethodValue.self).first.or(throw: "No paymentMethod")
            let total = try (pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Total.self).first?.total).or(throw: "No total confirmation")
            let fee = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.FiatTransactionFee.self).first.or(throw: "No fee")

            let paymentMethodAccount = source as? PaymentMethodAccount
            let name: String
            let detail: String?

            switch paymentMethodAccount?.paymentMethodType {
            case .card(let card):
                name = card.type.name
                detail = card.displaySuffix
            case .applePay(let apple):
                name = LocalizationConstants.Checkout.applePay
                detail = apple.displaySuffix
            case .account:
                name = LocalizationConstants.Checkout.funds
                detail = nil
            case .linkedBank(let bank):
                name = bank.account?.bankName ?? LocalizationConstants.Checkout.bank
                detail = bank.account?.number
            case _:
                name = paymentMethod.name
                detail = nil
            }

            return try BuyCheckout(
                buyType: pendingTransaction.recurringBuyFrequency == .once ? .simpleBuy : .recurringBuy,
                input: value.baseValue,
                purchase: MoneyValuePair(
                    fiatValue: purchase.fiatValue.or(throw: "Amount is not fiat"),
                    exchangeRate: exchangeRate.baseValue.fiatValue.or(throw: "No exchange rate"),
                    cryptoCurrency: CryptoCurrency(code: value.baseValue.code).or(throw: "Input is not a crypto value"),
                    usesFiatAsBase: true
                ),
                fee: .init(
                    value: fee.fee.fiatValue.or(throw: "Fee is not in fiat"),
                    promotion: nil
                ),
                total: total.fiatValue.or(throw: "No total value"),
                paymentMethod: .init(
                    name: name,
                    detail: detail,
                    isApplePay: paymentMethodAccount?.paymentMethod.type.isApplePay == true,
                    isACH: paymentMethodAccount?.paymentMethod.type.isACH == true
                ),
                quoteExpiration: pendingTransaction.confirmations.lazy
                    .filter(TransactionConfirmations.QuoteExpirationTimer.self).first?.expirationDate,
                recurringBuyDetails: pendingTransaction.recurringBuyDetails
            )
        } catch {
            return nil
        }
    }

    var swapCheckout: SwapCheckout? {
        guard let pendingTransaction else { return nil }
        guard
            let sourceValue = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.SwapSourceValue.self).first?.cryptoValue,
            let destinationValue = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.SwapDestinationValue.self).first?.cryptoValue,
            let source = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Source.self).first?.value,
            let destination = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Destination.self).first?.value
        else { return nil }
        let sourceFee = pendingTransaction.confirmations.lazy
            .filter(TransactionConfirmations.NetworkFee.self)
            .first(where: \.feeType == .depositFee)?.primaryCurrencyFee.cryptoValue
        let destinationFee = pendingTransaction.confirmations.lazy
            .filter(TransactionConfirmations.NetworkFee.self)
            .first(where: \.feeType == .withdrawalFee)?.primaryCurrencyFee.cryptoValue
        let quoteExpiration = pendingTransaction.confirmations.lazy
            .filter(TransactionConfirmations.QuoteExpirationTimer.self).first?.expirationDate

        return SwapCheckout(
            from: SwapCheckout.Target(
                name: source,
                isPrivateKey: self.source?.accountType == .nonCustodial,
                cryptoValue: sourceValue,
                fee: sourceFee ?? .zero(currency: sourceValue.currency),
                exchangeRateToFiat: nil,
                feeExchangeRateToFiat: nil
            ),
            to: SwapCheckout.Target(
                name: destination,
                isPrivateKey: self.destination?.accountType == .nonCustodial,
                cryptoValue: destinationValue,
                fee: destinationFee ?? .zero(currency: destinationValue.currency),
                exchangeRateToFiat: nil,
                feeExchangeRateToFiat: nil
            ),
            quoteExpiration: quoteExpiration
        )
    }
}

extension BlockchainAccount {

    var isACH: Bool {
        (self as? PaymentMethodAccount)?.paymentMethod.type.isACH ?? false
    }

    func checkoutPaymentMethod() -> BuyCheckout.PaymentMethod {
        switch (self as? PaymentMethodAccount)?.paymentMethodType {
        case .card(let card):
            return BuyCheckout.PaymentMethod(
                name: card.type.name,
                detail: card.displaySuffix,
                isApplePay: false,
                isACH: isACH
            )
        case .applePay(let apple):
            return BuyCheckout.PaymentMethod(
                name: LocalizationConstants.Checkout.applePay,
                detail: apple.displaySuffix,
                isApplePay: true,
                isACH: isACH
            )
        case .account:
            return BuyCheckout.PaymentMethod(
                name: LocalizationConstants.Checkout.funds,
                detail: nil,
                isApplePay: false,
                isACH: isACH
            )
        case .linkedBank(let bank):
            return BuyCheckout.PaymentMethod(
                name: bank.account?.bankName ?? LocalizationConstants.Checkout.bank,
                detail: bank.account?.number,
                isApplePay: false,
                isACH: isACH
            )
        case _:
            return BuyCheckout.PaymentMethod(
                name: label,
                detail: nil,
                isApplePay: false,
                isACH: isACH
            )
        }
    }
}
