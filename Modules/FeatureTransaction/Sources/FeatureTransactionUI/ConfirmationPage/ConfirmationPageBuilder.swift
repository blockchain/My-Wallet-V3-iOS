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
        case .send:
            viewController = buildSendCheckout(for: transactionModel)
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

    private func buildSendCheckout(for transactionModel: TransactionModel) -> UIViewController {
        let publisher = transactionModel.state.publisher
            .ignoreFailure(setFailureType: Never.self)
            .compactMap(\.sendCheckout)
            .removeDuplicates()

        let onMemoUpdated: (SendCheckout.Memo) -> Void = { memo in
            let model = TransactionConfirmations.Memo(textMemo: memo.value, required: memo.required)
            transactionModel.process(action: .modifyTransactionConfirmation(model))
        }

        let viewController = UIHostingController(
            rootView: SendCheckoutView(publisher: publisher, onMemoUpdated: onMemoUpdated)
                .onAppear { transactionModel.process(action: .validateTransaction) }
                .navigationTitle(LocalizationConstants.Checkout.send)
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

    private func buildBuyCheckout(for transactionModel: TransactionModel) -> UIViewController {

        let publisher = transactionModel.state.publisher
            .ignoreFailure(setFailureType: Never.self)
            .flatMap { [app] state -> AnyPublisher<(TransactionState, Bool), Never> in
                app.publisher(for: blockchain.ux.transaction.payment.method.is.available.for.recurring.buy, as: Bool.self)
                    .map(\.value)
                    .combineLatest(
                        app.publisher(for: blockchain.ux.transaction.action.select.recurring.buy.frequency, as: RecurringBuy.Frequency.self)
                            .map(\.value)
                    )
                    .map({ isAvailable, frequency -> Bool in
                        let isAvailable = isAvailable ?? false
                        let frequency = frequency ?? .once
                        return isAvailable && frequency == .once
                    })
                    .map { (state, $0) }
                    .eraseToAnyPublisher()
            }
            .compactMap { state, displayInvestWeekly -> BuyCheckout? in
                state.provideBuyCheckout(shouldDisplayInvestWeekly: displayInvestWeekly)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()

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
                            app.state.clear(blockchain.ux.transaction.checkout.recurring.buy.invest.weekly)
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

        app.publisher(for: blockchain.ux.transaction["buy"].checkout.recurring.buy.invest.weekly, as: Bool.self)
            .map(\.value)
            .sink { value in
                guard let value = value else { return }
                let frequency: RecurringBuy.Frequency = value ? .weekly : .once
                transactionModel.process(action: .updateRecurringBuyFrequency(frequency))
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

    func provideBuyCheckout(shouldDisplayInvestWeekly: Bool) -> BuyCheckout? {
        guard let source, let quote, let result = quote.result else { return nil }
        do {
            let fee = quote.fee
            return try BuyCheckout(
                buyType: pendingTransaction?.recurringBuyFrequency == .once ? .simpleBuy : .recurringBuy,
                input: quote.amount,
                purchase: result,
                fee: fee.withoutPromotion.map {
                    try .init(value: $0.fiatValue.or(throw: "Buy fee is expected in fiat"), promotion: fee.value?.fiatValue)
                },
                total: quote.amount.fiatValue.or(throw: "Expected fiat"),
                paymentMethod: source.checkoutPaymentMethod(),
                quoteExpiration: quote.date.expiresAt,
                recurringBuyDetails: pendingTransaction?.recurringBuyDetails,
                depositTerms: .init(
                    availableToTrade: quote.depositTerms?.formattedAvailableToTrade,
                    availableToWithdraw: quote.depositTerms?.formattedAvailableToWithdraw,
                    withdrawalLockInDays: quote.depositTerms?.formattedWithdrawalLockDays
                ),
                displaysInvestWeekly: shouldDisplayInvestWeekly
            )
        } catch {
            return nil
        }
    }

    var sendCheckout: SendCheckout? {
        guard let pendingTransaction else { return nil }
        do {
            let source = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Source.self).first.or(throw: "No source confirmation")
            let destination = try pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Destination.self).first.or(throw: "No destination confirmation")

            let sourceTarget = SendCheckout.Target(
                name: source.value,
                isPrivateKey: self.source?.accountType == .nonCustodial
            )
            let destinationTarget = SendCheckout.Target(
                name: destination.value,
                isPrivateKey: self.destination?.accountType == .nonCustodial
            )

            var memo: SendCheckout.Memo?
            if let memoValue = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Memo.self).first
            {
                memo = SendCheckout.Memo(value: memoValue.value?.string, required: memoValue.required)
            }

            let amountPair: SendCheckout.Amount

            // SendDestinationValue only appears on OnChainTransaction engines
            if pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.SendDestinationValue.self).first?.value != nil
            {
                let feeTotal = try pendingTransaction.confirmations.lazy
                    .filter(TransactionConfirmations.FeedTotal.self).first.or(throw: "No fee total confirmation")

                amountPair = SendCheckout.Amount(value: feeTotal.amount, fiatValue: feeTotal.amountInFiat)

                let feeLevel: FeeLevel = pendingTransaction.confirmations.lazy
                    .filter(TransactionConfirmations.FeeSelection.self)
                    .map(\.selectedLevel)
                    .first
                    .or(default: .regular)

                let checkoutFee = SendCheckout.Fee(
                    type: .network(level: feeLevel.title),
                    value: feeTotal.fee,
                    exchange: feeTotal.feeInFiat
                )
                let total: MoneyValue
                let totalFiat: MoneyValue
                let totalPair: SendCheckout.Amount
                if feeTotal.amount.currency == feeTotal.fee.currency {
                    total = try feeTotal.amount + feeTotal.fee
                    totalFiat = try feeTotal.amountInFiat + feeTotal.feeInFiat
                    totalPair = SendCheckout.Amount(value: total, fiatValue: totalFiat)
                } else {
                    total = feeTotal.amount
                    totalFiat = feeTotal.amountInFiat
                    totalPair = SendCheckout.Amount(value: total, fiatValue: totalFiat)
                }

                return SendCheckout(
                    amount: amountPair,
                    from: sourceTarget,
                    to: destinationTarget,
                    fee: checkoutFee,
                    total: totalPair,
                    memo: memo
                )
            }
            // Amount only appears on TradingToOnChain engine
            else if let amountEntry = pendingTransaction.confirmations.lazy
                .filter(TransactionConfirmations.Amount.self).first
            {
                let fiatValue = amountEntry.exchange.map(MoneyValue.init(fiatValue:))
                amountPair = SendCheckout.Amount(value: amountEntry.amount, fiatValue: fiatValue)
                let processingFee = try pendingTransaction.confirmations.lazy
                    .filter(TransactionConfirmations.ProccessingFee.self).first.or(throw: "No processing fee confirmation")
                let fee = SendCheckout.Fee(type: .processing, value: processingFee.fee, exchange: processingFee.exchange)
                let totalValue = try pendingTransaction.confirmations.lazy
                    .filter(TransactionConfirmations.SendTotal.self).first.or(throw: "No total confirmation")
                let total = SendCheckout.Amount(value: totalValue.total, fiatValue: totalValue.exchange)
                return SendCheckout(
                    amount: amountPair,
                    from: sourceTarget,
                    to: destinationTarget,
                    fee: fee,
                    total: total,
                    memo: memo
                )
            } else {
                return nil
            }
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
