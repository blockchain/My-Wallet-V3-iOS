//
//  SendXLMCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import PlatformKit
import PlatformUIKit
import RxSwift
import StellarKit
import ToolKit

class SendXLMCoordinator {
    fileprivate let serviceProvider: StellarServiceProvider
    fileprivate let interface: SendXLMInterface
    fileprivate let modelInterface: SendXLMModelInterface
    fileprivate let disposables = CompositeDisposable()
    fileprivate var services: StellarDependenciesAPI {
        serviceProvider.services
    }
    private let analyticsRecorder: AnalyticsEventRecording
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    
    /// Exchange address presenter
    private let exchangeAddressPresenter: SendExchangeAddressStatePresenter
    private var exchangeAddressViewModel = ExchangeAddressViewModel(cryptoCurrency: .stellar)
    
    /// The source of the address
    private var addressSource = SendAssetAddressSource.standard
    
    /// The Exchange address
    private var exchangeAddress: String!
    private var exchangeMemo: String!

    private let bag = DisposeBag()
    
    init(serviceProvider: StellarServiceProvider,
         interface: SendXLMInterface,
         modelInterface: SendXLMModelInterface,
         exchangeAddressPresenter: SendExchangeAddressStatePresenter,
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        self.fiatCurrencyService = fiatCurrencyService
        self.serviceProvider = serviceProvider
        self.interface = interface
        self.modelInterface = modelInterface
        self.exchangeAddressPresenter = exchangeAddressPresenter
        self.analyticsRecorder = analyticsRecorder
        if let controller = interface as? SendLumensViewController {
            controller.delegate = self
        }
    }

    deinit {
        disposables.dispose()
    }
    
    enum InternalEvent {
        case insufficientFundsForNewAccount
        case insufficientFunds
        case noStellarAccount
    }
    
    // MARK: Private Functions
    
    private func isExchangeAddress() -> Single<Bool> {
        Single.just(addressSource == .exchange)
    }

    fileprivate func accountDetailsTrigger() -> Observable<StellarAccount> {
        services.operation.operations.concatMap { result -> Observable<StellarAccount> in
            self.services.accounts.currentStellarAccount(fromCache: false).asObservable()
        }
    }
    
    fileprivate func observeOperations() {
        let disposable = Observable
            .combineLatest(accountDetailsTrigger(), services.ledger.current)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (account, ledger) in
                // TODO:
            }, onError: { error in
                guard error is StellarServiceError else { return }
                Logger.shared.error(error.localizedDescription)
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    fileprivate func handle(internalEvent: InternalEvent) {
        switch internalEvent {
        case .insufficientFunds:
            // TODO
            break
        case .noStellarAccount:
            let trigger = ActionableTrigger(text: "Minimum of", CTA: "1 XLM", secondary: "needed for new accounts.") {
                // TODO: On `1 XLM` selection, show the minimum balance screen.
            }
            interface.apply(updates: [.actionableLabelTrigger(trigger),
                                      .fiatFieldTextColor(.error),
                                      .xlmFieldTextColor(.error),
                                      .errorLabelVisibility(.hidden),
                                      .feeAmountLabelText])
        case .insufficientFundsForNewAccount:
            interface.apply(updates: [.errorLabelVisibility(.visible),
                                      .errorLabelText(LocalizationConstants.Stellar.minimumForNewAccountsError)])
        }
    }

    fileprivate func updateFiatEntryInterface(text: String?) {
        interface.apply(updates: [
            .fiatAmountText(text),
            .errorLabelVisibility(.hidden),
            .fiatFieldTextColor(.gray6),
            .xlmFieldTextColor(.gray6)
        ])
    }

    fileprivate func updateXlmEntryInterface(text: String?) {
        interface.apply(updates: [
            .stellarAmountText(text),
            .errorLabelVisibility(.hidden),
            .fiatFieldTextColor(.gray6),
            .xlmFieldTextColor(.gray6)
        ])
    }
}

extension SendXLMCoordinator: SendXLMViewControllerDelegate {
    func onLoad() {
        interface.apply(updates: [.exchangeAddressButtonVisibility(.hidden),
                                  .useExchangeAddress(nil)])
        
        // Fetch the Exchange address for asset and apply changes to the interface
        exchangeAddressPresenter.viewModel
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] viewModel in
                guard let self = self else { return }
                self.exchangeAddressViewModel = viewModel
                let split = viewModel.address?.components(separatedBy: ":") ?? []
                self.exchangeAddress = split.first ?? ""
                self.exchangeMemo = split.last ?? ""
                self.interface.apply(updates: [.exchangeAddressButtonVisibility(.visible)])
            }, onError: { [weak self] error in
                self?.interface.apply(updates: [.exchangeAddressButtonVisibility(.hidden)])
            })
            .disposed(by: bag)
        
        initializeActionableLabel()
        // TODO: Users may have a `defaultAccount` but that doesn't mean
        // that they have an `StellarAccount` as it must be funded.
        let disposable = services.accounts.currentStellarAccount(fromCache: true).asObservable()
            .subscribeOn(MainScheduler.asyncInstance)
            .filter { account -> Bool in
                /// The user has a StellarAccount, we should enable the input fields.
                /// Begin observing operations and updating the user account.
                /// If the user does not have a balance, it means the `StellarAccount`
                /// does not exist (it hasn't been funded).
                guard account.assetAccount.balance.amount > 0 else {
                    throw StellarAccountError.noDefaultAccount
                }
                return true
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] account in
                if account.assetAccount.balance.amount == 0 {
                    self?.handle(internalEvent: .noStellarAccount)
                }
                self?.observeOperations()
            }, onError: { [weak self] error in
                guard let this = self else { return }
                guard let serviceError = error as? StellarAccountError else { return }
                switch serviceError {
                case .noXLMAccount:
                    this.handle(internalEvent: .noStellarAccount)
                case .noDefaultAccount:
                    this.handle(internalEvent: .noStellarAccount)
                case .unableToSaveNewAccount:
                    this.handle(internalEvent: .noStellarAccount)
                }
                this.handle(internalEvent: .insufficientFunds)
                Logger.shared.error(error.localizedDescription)
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    func onAppear() {
        if let xlmAccount = services.repository.defaultAccount {
            computeMaxSpendableAmount(for: xlmAccount.publicKey)
        }

        let fiatCurrency = BlockchainSettings.App.shared.fiatCurrency
        interface.apply(updates: [.fiatSymbolLabel(fiatCurrency.code)])
        
        let disposable = Single.zip(
                services.prices.price(for: CryptoCurrency.stellar, in: fiatCurrency),
                services.ledger.current.take(1).asSingle(),
                services.feeService.fees
            )
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] price, ledger, fee in
                guard let self = self else { return }
                guard let _ = ledger.baseFeeInXlm else {
                    Logger.shared.error("Fee is nil.")
                    self.interface.apply(updates: [
                        .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                        .errorLabelVisibility(.visible)
                    ])
                    return
                }
                
                let feeInXlm: Decimal = fee.regular.displayMajorValue
                
                self.modelInterface.updateBaseReserve(ledger.baseReserveInXlm?.displayMajorValue)
                self.modelInterface.updateFee(feeInXlm)
                self.modelInterface.updatePrice(price.moneyValue.displayMajorValue)
                self.interface.apply(updates: [.feeAmountLabelText])
            }, onError: { [unowned self] error in
                Logger.shared.error(error.localizedDescription)
                self.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Errors.genericError),
                    .errorLabelVisibility(.visible)
                ])
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    func onMemoTextSelection() {
        guard addressSource != .exchange else { return }
        interface.apply(updates: [.memoTextFieldVisibility(.visible),
                                  .memoIDTextFieldVisibility(.hidden),
                                  .memoTextFieldShouldBeginEditing,
                                  .memoSelectionButtonVisibility(.hidden)])
    }
    
    func onMemoIDSelection() {
        interface.apply(updates: [.memoIDTextFieldVisibility(.visible),
                                  .memoTextFieldVisibility(.hidden),
                                  .memoIDFieldShouldBeginEditing,
                                  .memoSelectionButtonVisibility(.hidden)])
    }
    
    func onXLMEntry(_ value: String, latestPrice: Decimal) {
        guard let decimal = Decimal(string: value) else {
            modelInterface.updateXLMAmount(nil)
            updateFiatEntryInterface(text: nil)
            return
        }
        modelInterface.updateXLMAmount(NSDecimalNumber(string: value).decimalValue)
        let fiat = NSDecimalNumber(decimal: latestPrice).multiplying(by: NSDecimalNumber(decimal: decimal))
        guard let fiatText = NumberFormatter.localCurrencyFormatter.string(from: fiat) else {
            Logger.shared.error("Could not format fiat text")
            updateFiatEntryInterface(text: "\(fiat)")
            return
        }

        updateFiatEntryInterface(text: fiatText)
    }
    
    func onFiatEntry(_ value: String, latestPrice: Decimal) {
        guard let decimal = Decimal(string: value) else {
            modelInterface.updateXLMAmount(nil)
            updateXlmEntryInterface(text: nil)
            return
        }
        let crypto = NSDecimalNumber(decimal: decimal).dividing(by: NSDecimalNumber(decimal: latestPrice))
        modelInterface.updateXLMAmount(crypto.decimalValue)
        guard let cryptoText = NumberFormatter.stellarFormatter.string(from: crypto) else {
            Logger.shared.error("Could not format crypto text")
            updateXlmEntryInterface(text: "\(crypto)")
            return
        }
        updateXlmEntryInterface(text: cryptoText)
    }
    
    func onStellarAddressEntry(_ value: String?) {
        var updates: [SendLumensViewController.PresentationUpdate] = [
            .stellarAddressTextColor(.gray6),
            .errorLabelVisibility(.hidden)
        ]
        if let entry = value {
            Single.zip(services.accounts.isExchangeAddress(entry), isExchangeAddress())
                .map { $0 && $1 }
                .observeOn(MainScheduler.instance)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(onSuccess: { [weak self] (isExchangeAddress) in
                    guard let self = self else { return }
                    let visibility: Visibility = isExchangeAddress ? .visible : .hidden
                    updates.append(.memoRequiredDisclaimerVisibility(visibility))
                    self.interface.apply(updates: updates)
                })
                .disposed(by: bag)
        } else {
            updates.append(.memoRequiredDisclaimerVisibility(.hidden))
            interface.apply(updates: updates)
        }
    }

    func onConfirmPayTapped(_ paymentOperation: StellarPaymentOperation) {
        analyticsRecorder.record(event: AnalyticsEvents.Send.sendSummaryConfirmClick(asset: .stellar))
        let transaction = services.transaction
        let disposable = services.repository.loadKeyPair()
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.interface.apply(updates: [
                    .hidePaymentConfirmation,
                    .activityIndicatorVisibility(.visible),
                    .primaryButtonEnabled(false)
                ])
            })
            .flatMap { keyPair -> Completable in
                transaction.send(paymentOperation, sourceKeyPair: keyPair)
            }
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                guard let self = self else { return }
                Logger.shared.error("Failed to send XLM. Error: \(error)")
                self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendSummaryConfirmFailure(asset: .stellar))
                let errorMessage: String
                if let stellarError = error as? StellarPaymentOperationError, stellarError == .cancelled {
                    // User cancelled transaction when shown second password - do not show an error.
                    return
                } else if let stellarError = error as? StellarFundsError, stellarError == .insufficientFundsForNewAccount {
                    errorMessage = LocalizationConstants.Stellar.minimumForNewAccountsError
                } else {
                    errorMessage = LocalizationConstants.Stellar.cannotSendXLMAtThisTime
                }
                
                self.interface.apply(updates: [
                    .errorLabelText(errorMessage),
                    .errorLabelVisibility(.visible),
                    .activityIndicatorVisibility(.hidden),
                    .primaryButtonEnabled(true)
                ])
            }, onCompleted: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendSummaryConfirmSuccess(asset: .stellar))
                self.services.walletActionEventBus.publish(
                    action: .sendCrypto,
                    extras: [WalletAction.ExtraKeys.assetType: CryptoCurrency.stellar]
                )
                self.computeMaxSpendableAmount(for: paymentOperation.sourceAccount.publicKey)
                self.interface.apply(updates: [
                    .fiatAmountText(""),
                    .stellarAmountText(""),
                    .paymentSuccess,
                    .activityIndicatorVisibility(.hidden),
                    .primaryButtonEnabled(true),
                    .memoSelectionButtonVisibility(.visible),
                    .memoTextFieldVisibility(.visible),
                    .memoIDTextFieldVisibility(.hidden)
                ])
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    func onPrimaryTapped(toAddress: String, amount: Decimal, feeInXlm: Decimal, memo: StellarMemoType?) {
        analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormConfirmClick(asset: .stellar))
        guard let sourceAccount = services.repository.defaultAccount else {
            interface.apply(updates: [
                .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                .errorLabelVisibility(.visible)
            ])
            return
        }
        
        let amountString = (amount as NSDecimalNumber).description(withLocale: Locale.current)
        guard let amountCrypto = CryptoValue.stellar(majorDisplay: amountString) else {
            interface.apply(updates: [
                .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                .errorLabelVisibility(.visible)
            ])
            return
        }
        
        let disposable = Single.zip(
            services.limits.isSpendable(amount: amountCrypto, for: sourceAccount.publicKey),
            services.accounts.validate(accountID: toAddress),
            services.accounts.isExchangeAddress(toAddress)
        ).subscribeOn(MainScheduler.asyncInstance)
        .observeOn(MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] isSpendable, isValidDestination, isExchangeAddress in
            guard let self = self else { return }
            guard isSpendable else {
                self.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Stellar.notEnoughXLM),
                    .errorLabelVisibility(.visible),
                    .fiatFieldTextColor(.error),
                    .xlmFieldTextColor(.error)
                ])
                return
            }
            guard isValidDestination else {
                self.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Stellar.invalidDestinationAddress),
                    .errorLabelVisibility(.visible),
                    .stellarAddressTextColor(.error)
                ])
                return
            }
            
            if isExchangeAddress == true && memo == nil {
                self.interface.apply(updates: [.memoRequiredDisclaimerVisibility(.visible)])
                return
            }
            
            let displayAddress: String
            switch self.addressSource {
            case .exchange:
                displayAddress = String(
                    format: LocalizationConstants.Exchange.Send.destination,
                    CryptoCurrency.stellar.displayCode
                )
            case .standard:
                displayAddress = toAddress
            }
            
            let operation = StellarPaymentOperation(
                destinationAccountDisplayName: displayAddress,
                destinationAccountId: toAddress,
                amountInXlm: amount,
                sourceAccount: sourceAccount,
                feeInXlm: feeInXlm,
                memo: memo
            )
            self.interface.apply(updates: [
                .showPaymentConfirmation(operation),
                .errorLabelVisibility(.hidden),
                .stellarAddressTextColor(.gray6)
            ])
            self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormConfirmSuccess(asset: .stellar))
        }, onError: { [weak self] error in
            guard let self = self else { return }
            Logger.shared.error("Could not fetch ledger or account details")
            self.interface.apply(updates: [
                .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                .errorLabelVisibility(.visible)
            ])
            self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormConfirmFailure(asset: .stellar))
        })
        disposables.insertWithDiscardableResult(disposable)
    }

    func onMinimumBalanceInfoTapped() {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<(PriceQuoteAtTime, StellarLedger, StellarAccount)> in
                Single.zip(self.services.prices.price(for: CryptoCurrency.stellar, in: fiatCurrency),
                           self.services.ledger.current.take(1).asSingle(),
                           self.services.accounts.currentStellarAccount(fromCache: true)
                            .ifEmpty(default: StellarAccount.empty())
                )
            }
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] price, ledger, account in
                guard let self = self else { return }
                self.showMinimumBalanceView(
                    latestPrice: price.moneyValue.displayMajorValue,
                    fee: ledger.baseFeeInXlm?.displayMajorValue ?? self.services.ledger.fallbackBaseFee,
                    balance: account.assetAccount.balance.displayMajorValue,
                    baseReserve: ledger.baseReserveInXlm?.displayMajorValue ?? self.services.ledger.fallbackBaseReserve
                )
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                self.showMinimumBalanceView(
                    latestPrice: 0,
                    fee: self.services.ledger.fallbackBaseFee,
                    balance: 0,
                    baseReserve: self.services.ledger.fallbackBaseReserve
                )
            })
            .disposed(by: bag)
    }

    func onExchangeAddressButtonTapped() {
        switch addressSource {
        case .exchange:
            addressSource = .standard
            interface.apply(updates: [.useExchangeAddress(nil),
                                      .memoTextFieldText(nil),
                                      .memoTextFieldVisibility(.visible),
                                      .memoIDTextFieldVisibility(.hidden),
                                      .memoSelectionButtonVisibility(.visible)])
        case .standard:
            analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormExchangeButtonClick(asset: .stellar))
            if !exchangeAddressViewModel.isTwoFactorEnabled {
                interface.apply(updates: [.showAlertForEnabling2FA])
            } else {
                addressSource = .exchange
                interface.apply(
                    updates: [
                        .useExchangeAddress(exchangeAddress),
                        .memoTextFieldText(exchangeMemo),
                        .memoTextFieldVisibility(.visible),
                        .memoIDTextFieldVisibility(.hidden),
                        .memoSelectionButtonVisibility(.hidden)
                    ])
            }
        }
    }
    
    var sendingToExchange: Bool {
        addressSource == .exchange
    }
    
    // MARK: - Private

    private func showMinimumBalanceView(
        latestPrice: Decimal,
        fee: Decimal,
        balance: Decimal,
        baseReserve: Decimal
    ) {
        let viewModel = InformationViewModel.createForStellarMinimum(
            latestPrice: latestPrice,
            fee: fee,
            balance: balance,
            baseReserve: baseReserve,
            buttonAction: { viewController in
                let webViewServiceAPI: WebViewServiceAPI = resolve()
                webViewServiceAPI.openSafari(
                    url: Constants.Url.stellarMinimumBalanceInfo,
                    from: viewController
                )
            }
        )
        let viewController = InformationViewController.make(viewModel: viewModel)
        let navigationController = BCNavigationController(rootViewController: viewController, title: LocalizationConstants.Stellar.minimumBalance)
        navigationController.modalPresentationStyle = .fullScreen
        interface.present(viewController: navigationController)
    }

    private func initializeActionableLabel() {
        // Initialize with 0
        interface.apply(updates: [
            .actionableLabelTrigger(ActionableTrigger(
                text: LocalizationConstants.Stellar.useSpendableBalanceX,
                CTA: "... \(CryptoCurrency.stellar.displayCode)",
                executionBlock: {}
            ))
        ])
    }

    private func computeMaxSpendableAmount(for accountId: String) {
        let fiatCurrency = BlockchainSettings.App.shared.fiatCurrency
        let disposable = Single.zip(
            services.prices.price(for: CryptoCurrency.stellar, in: fiatCurrency),
            services.limits.maxSpendableAmount(for: accountId)
        ).subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] price, maxSpendableAmount in
                let stellarMaxString = maxSpendableAmount.toDisplayString(includeSymbol: false)
                let fiatMaxString = maxSpendableAmount
                    .convertToFiatValue(exchangeRate: price.moneyValue.fiatValue!)
                    .toDisplayString(includeSymbol: false)
                let trigger = ActionableTrigger(
                    text: LocalizationConstants.Stellar.useSpendableBalanceX,
                    CTA: "\(stellarMaxString) \(CryptoCurrency.stellar.displayCode)",
                    executionBlock: {
                        self?.interface.apply(updates: [
                            .stellarAmountText(stellarMaxString),
                            .fiatAmountText(fiatMaxString)
                        ])
                        self?.onXLMEntry(stellarMaxString, latestPrice: price.moneyValue.displayMajorValue)
                    }
                )
                self?.interface.apply(updates: [
                    .actionableLabelTrigger(trigger)
                ])
            }, onError: { error in
                Logger.shared.error("Could not compute max spendable amount.")
            })
        disposables.insertWithDiscardableResult(disposable)
    }
}

// MARK: Extensions

extension StellarAccount {
    static func empty() -> StellarAccount {
        let assetAccount = AssetAccount(
            index: 0,
            address: StellarAssetAddress(publicKey: ""),
            balance: CryptoValue.stellarZero,
            name: ""
        )
        return StellarAccount(
            identifier: "",
            assetAccount: assetAccount,
            sequence: 0,
            subentryCount: 0
        )
    }
}

extension InformationViewModel {
    static func createForStellarMinimum(
        latestPrice: Decimal,
        fee: Decimal,
        balance: Decimal,
        baseReserve: Decimal,
        buttonAction: @escaping InformationViewButtonAction
    ) -> InformationViewModel {
        let bodyText = bodyTextForStellarMinimum(latestPrice: latestPrice, fee: fee, balance: balance, baseReserve: baseReserve)
        return InformationViewModel(
            informationText: bodyText,
            buttonTitle: LocalizationConstants.Stellar.readMore,
            buttonAction: buttonAction
        )
    }

    private static func bodyTextForStellarMinimum(
        latestPrice: Decimal,
        fee: Decimal,
        balance: Decimal,
        baseReserve: Decimal
    ) -> NSAttributedString? {
        let assetType: CryptoCurrency = .stellar
        let explanation = LocalizationConstants.Stellar.minimumBalanceInfoExplanation

        let minimum = baseReserve * 2
        let current = String(format: LocalizationConstants.Stellar.minimumBalanceInfoCurrentArgument, "\(minimum)".appendAssetSymbol(for: assetType))

        let totalText = LocalizationConstants.Stellar.totalFundsLabel
        let totalAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: balance,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let requirementText = LocalizationConstants.Stellar.xlmReserveRequirement
        let requirementAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: minimum,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let feeText = LocalizationConstants.Stellar.transactionFee
        let feeAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: fee,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let availableToSendMaybe = balance - minimum - fee
        let availableToSend = (availableToSendMaybe > 0) ? availableToSendMaybe : 0
        let availableToSendText = LocalizationConstants.Stellar.availableToSend
        let availableToSendAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: availableToSend,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let moreInformationText = LocalizationConstants.Stellar.minimumBalanceMoreInformation

        let defaultFont = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)!
        let defaultAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.gray5,
                                                                NSAttributedString.Key.font: defaultFont]

        let explanationPlusCurrent = NSAttributedString(
            string: "\(explanation)\n\n\(current)\n\n",
            attributes: defaultAttributes
        )
        let exampleOne = NSAttributedString(
            string: "\(totalText)\n\(totalAmount)\n\n\(requirementText)\n\(requirementAmount)\n\n",
            attributes: defaultAttributes
        )
        let exampleTwo = NSAttributedString(
            string: "\(feeText)\n\(feeAmount)\n\n",
            attributes: defaultAttributes
        )
        let available = NSAttributedString(
            string: "\(availableToSendText)\n\(availableToSendAmount)\n\n",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,
                         NSAttributedString.Key.font: UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.Small)!]
        )
        let footer = NSAttributedString(
            string: "\(moreInformationText)",
            attributes: defaultAttributes
        )

        let body = NSMutableAttributedString()
        [explanationPlusCurrent, exampleOne, exampleTwo, available, footer].forEach { body.append($0) }
        return body.copy() as? NSAttributedString
    }
}
