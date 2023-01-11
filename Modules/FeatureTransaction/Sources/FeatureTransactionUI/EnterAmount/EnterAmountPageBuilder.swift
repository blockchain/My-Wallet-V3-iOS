// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit
import UIKit

protocol EnterAmountPageBuildable {
    func build(
        listener: EnterAmountPageListener,
        sourceAccount: SingleAccount,
        destinationAccount: TransactionTarget,
        action: AssetAction,
        navigationModel: ScreenNavigationModel
    ) -> EnterAmountPageRouter
}

final class EnterAmountPageBuilder: EnterAmountPageBuildable {

    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let transactionModel: TransactionModel
    private let priceService: PriceServiceAPI
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let app: AppProtocol

    init(
        transactionModel: TransactionModel,
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        exchangeProvider: ExchangeProviding = resolve(),
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.priceService = priceService
        self.analyticsEventRecorder = analyticsEventRecorder
        self.transactionModel = transactionModel
        self.fiatCurrencyService = fiatCurrencyService
        self.app = app
    }

    // swiftlint:disable function_body_length
    func build(
        listener: EnterAmountPageListener,
        sourceAccount: SingleAccount,
        destinationAccount: TransactionTarget,
        action: AssetAction,
        navigationModel: ScreenNavigationModel
    ) -> EnterAmountPageRouter {
        let displayBundle = DisplayBundle.bundle(for: action, sourceAccount: sourceAccount, destinationAccount: destinationAccount)
        let amountViewable: AmountViewable
        let amountViewInteracting: AmountViewInteracting
        let amountViewPresenting: AmountViewPresenting
        let isQuickfillEnabled = app
            .remoteConfiguration
            .yes(if: blockchain.app.configuration.transaction.quickfill.is.enabled)
        let isRecurringBuyEnabled = app
            .remoteConfiguration
            .yes(if: blockchain.app.configuration.recurring.buy.is.enabled)

        let state = transactionModel
            .state
            .publisher

        let source = state.compactMap(\.source)
        let maxLimitPublisher = source.flatMap { [fiatCurrencyService] account -> AnyPublisher<MoneyValue, Error> in
            if let account = account as? PaymentMethodAccount {
                return .just(account.paymentMethodType.topLimit)
            }
            return fiatCurrencyService
                .tradingCurrencyPublisher
                .flatMap { fiatCurrency in
                    account
                        .fiatBalance(fiatCurrency: fiatCurrency)
                }
                .eraseToAnyPublisher()
        }
        .compactMap(\.fiatValue)
        .ignoreFailure(setFailureType: Never.self)
        .eraseToAnyPublisher()

        switch action {
        case .sell:
            guard let crypto = sourceAccount.currencyType.cryptoCurrency else {
                fatalError("Expected a crypto as a source account.")
            }
            guard let fiat = destinationAccount.currencyType.fiatCurrency else {
                fatalError("Expected a fiat as a destination account.")
            }
            amountViewInteracting = AmountTranslationInteractor(
                fiatCurrencyClosure: {
                    Observable.just(fiat)
                },
                cryptoCurrencyService: DefaultCryptoCurrencyService(currencyType: sourceAccount.currencyType),
                priceProvider: AmountTranslationPriceProvider(transactionModel: transactionModel),
                app: app,
                defaultCryptoCurrency: crypto,
                initialActiveInput: .fiat
            )

            amountViewPresenting = AmountTranslationPresenter(
                interactor: amountViewInteracting as! AmountTranslationInteractor,
                analyticsRecorder: analyticsEventRecorder,
                displayBundle: displayBundle.amountDisplayBundle,
                inputTypeToggleVisibility: .visible,
                app: app,
                maxLimitPublisher: maxLimitPublisher
            )

            amountViewable = AmountTranslationView(
                presenter: amountViewPresenting as! AmountTranslationPresenter,
                app: app,
                prefillButtonsEnabled: isQuickfillEnabled,
                shouldShowAvailableBalanceView: isQuickfillEnabled
            )
        case .swap,
             .send,
             .interestWithdraw,
             .interestTransfer,
             .stakingDeposit,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            guard let crypto = sourceAccount.currencyType.cryptoCurrency else {
                fatalError("Expected a crypto as a source account.")
            }
            amountViewInteracting = AmountTranslationInteractor(
                fiatCurrencyClosure: { [fiatCurrencyService] in
                    fiatCurrencyService.tradingCurrency.asObservable()
                },
                cryptoCurrencyService: DefaultCryptoCurrencyService(currencyType: sourceAccount.currencyType),
                priceProvider: AmountTranslationPriceProvider(transactionModel: transactionModel),
                app: app,
                defaultCryptoCurrency: crypto,
                initialActiveInput: .fiat
            )

            amountViewPresenting = AmountTranslationPresenter(
                interactor: amountViewInteracting as! AmountTranslationInteractor,
                analyticsRecorder: analyticsEventRecorder,
                displayBundle: displayBundle.amountDisplayBundle,
                inputTypeToggleVisibility: .visible,
                app: app,
                maxLimitPublisher: maxLimitPublisher
            )

            amountViewable = AmountTranslationView(
                presenter: amountViewPresenting as! AmountTranslationPresenter,
                app: app,
                prefillButtonsEnabled: isQuickfillEnabled,
                shouldShowAvailableBalanceView: isQuickfillEnabled
            )

        case .deposit,
             .withdraw:
            amountViewInteracting = SingleAmountInteractor(
                currencyService: fiatCurrencyService,
                inputCurrency: sourceAccount.currencyType
            )

            amountViewPresenting = SingleAmountPresenter(
                interactor: amountViewInteracting as! SingleAmountInteractor
            )

            amountViewable = SingleAmountView(presenter: amountViewPresenting as! SingleAmountPresenter)

        case .buy:
            guard let cryptoAccount = destinationAccount as? CryptoAccount else {
                fatalError("Expected a crypto as a destination account.")
            }
            amountViewInteracting = AmountTranslationInteractor(
                fiatCurrencyClosure: { [fiatCurrencyService] in
                    fiatCurrencyService.tradingCurrency.asObservable()
                },
                cryptoCurrencyService: EnterAmountCryptoCurrencyProvider(transactionModel: transactionModel),
                priceProvider: AmountTranslationPriceProvider(transactionModel: transactionModel),
                app: app,
                defaultCryptoCurrency: cryptoAccount.asset,
                initialActiveInput: .fiat
            )

            amountViewPresenting = AmountTranslationPresenter(
                interactor: amountViewInteracting as! AmountTranslationInteractor,
                analyticsRecorder: analyticsEventRecorder,
                displayBundle: displayBundle.amountDisplayBundle,
                inputTypeToggleVisibility: .hidden,
                app: app,
                maxLimitPublisher: maxLimitPublisher
            )
            amountViewable = AmountTranslationView(
                presenter: amountViewPresenting as! AmountTranslationPresenter,
                app: app,
                prefillButtonsEnabled: isQuickfillEnabled,
                shouldShowRecurringBuyFrequency: isRecurringBuyEnabled
            )
        default:
            unimplemented()
        }

        let digitPadViewModel = provideDigitPadViewModel()
        let continueButtonTitle = String(format: LocalizationConstants.Transaction.preview, action.name)
        let continueButtonViewModel = ButtonViewModel.primary(with: continueButtonTitle)

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
        let highlightColor = Color.black.withAlphaComponent(0.08)
        let model = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .titleText),
            background: .init(highlightColor: highlightColor)
        )
        return DigitPadViewModel(
            padType: .number,
            customButtonViewModel: model,
            contentTint: .titleText,
            buttonHighlightColor: highlightColor
        )
    }
}
