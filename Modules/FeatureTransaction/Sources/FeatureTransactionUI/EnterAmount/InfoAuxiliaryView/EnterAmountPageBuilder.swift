// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import BlockchainUI
import DIKit
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit
import UIKit

public struct TransactionMinMaxValues: Equatable {
    var maxSpendableFiatValue: MoneyValue
    var maxSpendableCryptoValue: MoneyValue
    var minSpendableFiatValue: MoneyValue
    var minSpendableCryptoValue: MoneyValue

    init(
        maxSpendableFiatValue: MoneyValue,
        maxSpendableCryptoValue: MoneyValue,
        minSpendableFiatValue: MoneyValue,
        minSpendableCryptoValue: MoneyValue
    ) {
        self.maxSpendableFiatValue = maxSpendableFiatValue
        self.maxSpendableCryptoValue = maxSpendableCryptoValue
        self.minSpendableFiatValue = minSpendableFiatValue
        self.minSpendableCryptoValue = minSpendableCryptoValue
    }
}

final class EnterAmountPageBuilder {
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let transactionModel: TransactionModel
    private let priceService: PriceServiceAPI
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let app: AppProtocol
    private let action: AssetAction
    private let coincore: CoincoreAPI

    init(
        transactionModel: TransactionModel,
        action: AssetAction,
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        exchangeProvider: ExchangeProviding = resolve(),
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        app: AppProtocol = resolve(),
        coincore: CoincoreAPI = resolve()
    ) {
        self.priceService = priceService
        self.analyticsEventRecorder = analyticsEventRecorder
        self.transactionModel = transactionModel
        self.fiatCurrencyService = fiatCurrencyService
        self.app = app
        self.action = action
        self.coincore = coincore
    }

    func buildNewSwapEnterAmount(with source: BlockchainAccount?, target: TransactionTarget?) -> ViewableRouter<Interactable, ViewControllable>? {
        let publisher = transactionModel.state.publisher
            .compactMap { state -> TransactionMinMaxValues? in
                if state.source != nil {
                    return TransactionMinMaxValues(
                        maxSpendableFiatValue: state.maxSpendableWithActiveAmountInputType(.fiat),
                        maxSpendableCryptoValue: state.maxSpendableWithActiveAmountInputType(.crypto),
                        minSpendableFiatValue: state.minSpendableWithActiveAmountInputType(.fiat),
                        minSpendableCryptoValue: state.minSpendableWithActiveAmountInputType(.crypto)
                    )
                } else {
                    return nil
                }
            }
            .ignoreFailure(setFailureType: Never.self)
            .eraseToAnyPublisher()

        let swapEnterAmountReducer = SwapEnterAmount(
            app: resolve(),
            defaultSwaptPairsService: resolve(),
            supportedPairsInteractorService: resolve(),
            minMaxAmountsPublisher: publisher,
            dismiss: { [weak self] in
                self?.transactionModel.process(action: .resetFlow)
            },
            onPairsSelected: { source, target in
                Task {
                    if let blockchainAccount = try? await self.coincore.account(source).await(),
                       let targetBlockchainAccount = await (try? self.coincore.account(target).await()) as? TransactionTarget
                    {
                        self.transactionModel.process(
                            action: .initialiseWithSourceAndTargetAccount(
                                action: .swap,
                                sourceAccount: blockchainAccount,
                                target: targetBlockchainAccount
                            )
                        )
                        // Workaround needed because you can't update and initialise a transaction at the same time. Update requires the transaction to be initialised beforehand. Currently, the transaction model has no callback to know when the transaction has been initalised so for the time being I am doing this delay.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.transactionModel.process(action: .updateAmount(.zero(currency: blockchainAccount.currencyType)))
                        }
                    }
                }
            },
            onAmountChanged: { [weak self] amount in
                self?.app.post(value: amount.minorString, of: blockchain.ux.transaction.enter.amount.input.value)
                self?.transactionModel.process(action: .fetchPrice(amount: amount))
                self?.transactionModel.process(action: .updateAmount(amount))
            },
            onPreviewTapped: { [weak self] amount in
                self?.transactionModel.process(action: .updateAmount(amount))
                DispatchQueue.main.async {
                    self?.transactionModel.process(action: .confirmSwap)
                }
            }
        )

        var sourceInformation: SelectionInformation?
        if let source, let currency = source.currencyType.cryptoCurrency {
            sourceInformation = SelectionInformation(
                accountId: source.identifier,
                currency: currency
            )
        }

        var targetInformation: SelectionInformation?
        if let target = target as? BlockchainAccount, let currency = target.currencyType.cryptoCurrency {
            targetInformation = SelectionInformation(
                accountId: target.identifier,
                currency: currency
            )
        }

        let enterAmount = SwapEnterAmountView(
            store: Store(
                initialState: .init(sourceInformation: sourceInformation, targetInformation: targetInformation),
                reducer: { swapEnterAmountReducer }
            ))
            .app(app)
            .navigationTitle(LocalizationConstants.Swap.swap)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: IconButton(
                    icon: .navigationCloseButton(),
                    action: { [app] in
                        self.transactionModel.process(action: .returnToPreviousStep)
                        app.post(event: blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back)
                    }
                )
            )

        let viewController = UIHostingController(
            rootView: enterAmount
        )
        viewController.title = " "
        viewController.navigationItem.leftBarButtonItem = .init(customView: UIView())
        viewController.isModalInPresentation = true

        return ViewableRouter(
            interactor: Interactor(),
            viewController: viewController
        )
    }

    func buildNewSellEnterAmount() -> ViewableRouter<Interactable, ViewControllable>? {
        let minMaxPublisher = transactionModel.state.publisher
            .compactMap { state -> TransactionMinMaxValues? in
                if state.source != nil {
                    return TransactionMinMaxValues(
                        maxSpendableFiatValue: state.maxSpendableWithActiveAmountInputType(.fiat),
                        maxSpendableCryptoValue: state.maxSpendableWithActiveAmountInputType(.crypto),
                        minSpendableFiatValue: state.minSpendableWithActiveAmountInputType(.fiat),
                        minSpendableCryptoValue: state.minSpendableWithActiveAmountInputType(.crypto)
                    )
                } else {
                    return nil
                }
            }
            .ignoreFailure(setFailureType: Never.self)
            .eraseToAnyPublisher()

        let validationStatePublisher = transactionModel.state.publisher
            .compactMap { state -> TransactionValidationState? in
                state.pendingTransaction?.validationState
            }
            .ignoreFailure(setFailureType: Never.self)
            .eraseToAnyPublisher()

        let errorStatePublisher = transactionModel.state.publisher
            .compactMap { state -> TransactionErrorState? in
                state.errorState
            }
            .ignoreFailure(setFailureType: Never.self)
            .eraseToAnyPublisher()

        let sellEnterAmountReducer = SellEnterAmount(
            app: resolve(),
            onAmountChanged: { [weak self] amount in
                self?.app.post(value: amount.minorString, of: blockchain.ux.transaction.enter.amount.input.value)
                self?.transactionModel.process(action: .fetchPrice(amount: .one(currency: amount.currency)))
                self?.transactionModel.process(action: .updateAmount(amount))
            },
            onPreviewTapped: { [weak self] amount in
                self?.transactionModel.process(action: .updateAmount(amount))
                DispatchQueue.main.async {
                    self?.transactionModel.process(action: .prepareTransaction)
                }
            },
            minMaxAmountsPublisher: minMaxPublisher,
            validationStatePublisher: validationStatePublisher
        )

        let enterAmount = SellEnterAmountView(
            store: Store(
                initialState: .init(),
                reducer: { sellEnterAmountReducer }
            ))
            .batch {
                set(blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back.tap.then.pop, to: true)
            }
            .app(app)
            .navigationTitle(LocalizationConstants.Transaction.Sell.title)
            .navigationBarBackButtonHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: IconButton(
                    icon: .navigationCloseButton(),
                    action: { [app] in
                        self.transactionModel.process(action: .returnToPreviousStep)
                        app.post(event: blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back)
                    }
                )
            )

        let viewController = UIHostingController(
            rootView: enterAmount
        )
        viewController.title = " "
        viewController.navigationItem.leftBarButtonItem = .init(customView: UIView())

        return ViewableRouter(
            interactor: Interactor(),
            viewController: viewController
        )
    }

    func build(
        listener: EnterAmountPageListener,
        sourceAccount: SingleAccount,
        destinationAccount: TransactionTarget,
        action: AssetAction,
        navigationModel: ScreenNavigationModel,
        defaultFiatCurrency: FiatCurrency
    ) -> EnterAmountPageRouter {
        let displayBundle = DisplayBundle.bundle(for: action, sourceAccount: sourceAccount, destinationAccount: destinationAccount)
        let amountViewable: AmountViewable
        let amountViewInteracting: AmountViewInteracting
        let isQuickfillEnabled = app
            .remoteConfiguration
            .yes(if: blockchain.app.configuration.transaction.quickfill.is.enabled)
        let isRecurringBuyEnabled = app
            .remoteConfiguration
            .yes(if: blockchain.app.configuration.recurring.buy.is.enabled)

        switch action {
        case .sell:
            guard let cryptoCurrency = sourceAccount.currencyType.cryptoCurrency else {
                fatalError("Expected a crypto as a source account.")
            }
            guard let fiatCurrency = destinationAccount.currencyType.fiatCurrency else {
                fatalError("Expected a fiat as a destination account.")
            }
            let interactor = AmountTranslationInteractor(
                fiatCurrencyClosure: { .just(fiatCurrency) },
                cryptoCurrency: cryptoCurrency,
                priceProvider: AmountTranslationPriceProvider(transactionModel: transactionModel),
                defaultFiatCurrency: fiatCurrency,
                app: app,
                initialActiveInput: .fiat
            )
            let presenter = AmountTranslationPresenter(
                interactor: interactor,
                analyticsRecorder: analyticsEventRecorder,
                displayBundle: displayBundle.amountDisplayBundle,
                inputTypeToggleVisibility: .visible,
                app: app
            )
            amountViewInteracting = interactor
            amountViewable = AmountTranslationView(
                presenter: presenter,
                app: app,
                prefillButtonsEnabled: isQuickfillEnabled,
                shouldShowAvailableBalanceView: isQuickfillEnabled
            )

        case .swap,
             .send,
             .interestWithdraw,
             .interestTransfer,
             .stakingDeposit,
             .stakingWithdraw,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            guard let cryptoCurrency = sourceAccount.currencyType.cryptoCurrency else {
                fatalError("Expected a crypto as a source account.")
            }
            let interactor = AmountTranslationInteractor(
                fiatCurrencyClosure: { [fiatCurrencyService] in
                    fiatCurrencyService.tradingCurrency
                },
                cryptoCurrency: cryptoCurrency,
                priceProvider: AmountTranslationPriceProvider(transactionModel: transactionModel),
                defaultFiatCurrency: defaultFiatCurrency,
                app: app,
                initialActiveInput: .fiat
            )
            let presenter = AmountTranslationPresenter(
                interactor: interactor,
                analyticsRecorder: analyticsEventRecorder,
                displayBundle: displayBundle.amountDisplayBundle,
                inputTypeToggleVisibility: .visible,
                app: app
            )
            amountViewInteracting = interactor
            amountViewable = AmountTranslationView(
                presenter: presenter,
                app: app,
                prefillButtonsEnabled: isQuickfillEnabled,
                shouldShowAvailableBalanceView: isQuickfillEnabled
            )

        case .deposit,
             .withdraw:
            let interactor = SingleAmountInteractor(
                currencyService: fiatCurrencyService,
                inputCurrency: sourceAccount.currencyType
            )
            let presenter = SingleAmountPresenter(
                interactor: interactor
            )
            amountViewInteracting = interactor
            amountViewable = SingleAmountView(presenter: presenter)

        case .buy:
            guard let cryptoAccount = destinationAccount as? CryptoAccount else {
                fatalError("Expected a crypto as a destination account.")
            }
            let interactor = AmountTranslationInteractor(
                fiatCurrencyClosure: { [fiatCurrencyService] in
                    fiatCurrencyService.tradingCurrency
                },
                cryptoCurrency: cryptoAccount.asset,
                priceProvider: AmountTranslationPriceProvider(transactionModel: transactionModel),
                defaultFiatCurrency: defaultFiatCurrency,
                app: app,
                initialActiveInput: .fiat
            )
            let presenter = AmountTranslationPresenter(
                interactor: interactor,
                analyticsRecorder: analyticsEventRecorder,
                displayBundle: displayBundle.amountDisplayBundle,
                inputTypeToggleVisibility: .hidden,
                app: app
            )
            amountViewInteracting = interactor
            amountViewable = AmountTranslationView(
                presenter: presenter,
                app: app,
                prefillButtonsEnabled: isQuickfillEnabled,
                shouldShowRecurringBuyFrequency: isRecurringBuyEnabled
            )
        default:
            unimplemented()
        }

        let digitPadViewModel = provideDigitPadViewModel()
        let continueButtonTitle = String(format: LocalizationConstants.Transaction.preview, action.name)
        let continueButtonViewModel = ButtonViewModel.transactionPrimary(
            with: continueButtonTitle
        )

        let viewController = EnterAmountViewController(
            displayBundle: displayBundle,
            devicePresenterType: DevicePresenter.type,
            digitPadViewModel: digitPadViewModel,
            continueButtonViewModel: continueButtonViewModel,
            recoverFromInputError: { [transactionModel] in
                transactionModel.process(action: .showErrorRecoverySuggestion)
            },
            amountViewProvider: amountViewable
        )

        let interactor = EnterAmountPageInteractor(
            transactionModel: transactionModel,
            presenter: viewController,
            amountInteractor: amountViewInteracting,
            action: action,
            navigationModel: navigationModel
        )
        interactor.listener = listener

        let router = EnterAmountPageRouter(
            interactor: interactor,
            viewController: viewController
        )
        return router
    }

    // MARK: - Private methods

    private func provideDigitPadViewModel() -> DigitPadViewModel {
        let highlightColor = UIColor.semantic.title.withAlphaComponent(0.08)
        let model = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .semantic.title),
            background: .init(highlightColor: highlightColor)
        )
        return DigitPadViewModel(
            padType: .number,
            customButtonViewModel: model,
            contentTint: .semantic.title,
            buttonHighlightColor: highlightColor,
            backgroundColor: .semantic.light
        )
    }
}
