//
//  SendXLMCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class SendXLMCoordinator {
    fileprivate let serviceProvider: XLMServiceProvider
    fileprivate let interface: SendXLMInterface
    fileprivate let modelInterface: SendXLMModelInterface
    fileprivate let disposables = CompositeDisposable()
    fileprivate var services: XLMServices {
        return serviceProvider.services
    }

    init(
        serviceProvider: XLMServiceProvider,
        interface: SendXLMInterface,
        modelInterface: SendXLMModelInterface
    ) {
        self.serviceProvider = serviceProvider
        self.interface = interface
        self.modelInterface = modelInterface
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
        case noXLMAccount
    }
    
    // MARK: Private Functions

    fileprivate func accountDetailsTrigger() -> Observable<StellarAccount> {
        return services.operation.operations.concatMap { result -> Observable<StellarAccount> in
            return self.services.accounts.currentStellarAccount(fromCache: false).asObservable()
        }
    }
    
    fileprivate func observeOperations() {
        let disposable = Observable.combineLatest(accountDetailsTrigger(), services.ledger.current)
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
        case .noStellarAccount,
             .noXLMAccount:
            let trigger = ActionableTrigger(text: "Minimum of", CTA: "1 XLM", secondary: "needed for new accounts.") {
                // TODO: On `1 XLM` selection, show the minimum balance screen.
            }
            interface.apply(updates: [.actionableLabelTrigger(trigger),
                                      .fiatFieldTextColor(.error),
                                      .xlmFieldTextColor(.error),
                                      .errorLabelVisibility(.hidden),
                                      .feeAmountLabelText()])
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
                guard account.assetAccount.balance > 0 else {
                    throw StellarServiceError.noDefaultAccount
                }
                return true
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] account in
                if account.assetAccount.balance == 0 {
                    self?.handle(internalEvent: .noStellarAccount)
                }
                self?.observeOperations()
            }, onError: { [weak self] error in
                guard let this = self else { return }
                guard let serviceError = error as? StellarServiceError else { return }
                switch serviceError {
                case .noXLMAccount:
                    this.handle(internalEvent: .noXLMAccount)
                case .noDefaultAccount:
                    this.handle(internalEvent: .noStellarAccount)
                default:
                    break
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

        let fiatSymbol = BlockchainSettings.App.shared.fiatCurrencyCode
        interface.apply(updates: [.fiatSymbolLabel(fiatSymbol)])

        let disposable = Single.zip(
            services.prices.fiatPrice(forAssetType: .stellar, fiatSymbol: fiatSymbol),
            services.ledger.current.take(1).asSingle()
        ).subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] price, ledger in
                guard let feeInXlm = ledger.baseFeeInXlm else {
                    Logger.shared.error("Fee is nil.")
                    self.interface.apply(updates: [
                        .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                        .errorLabelVisibility(.visible)
                    ])
                    return
                }
                self.modelInterface.updateBaseReserve(ledger.baseReserveInXlm)
                self.modelInterface.updateFee(feeInXlm)
                self.modelInterface.updatePrice(price.price)
                self.interface.apply(updates: [.feeAmountLabelText()])
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

    func onStellarAddressEntry() {
        interface.apply(updates: [
            .stellarAddressTextColor(.gray6),
            .errorLabelVisibility(.hidden)
        ])
    }

    func onConfirmPayTapped(_ paymentOperation: StellarPaymentOperation) {
        let transaction = services.transaction
        let disposable = services.repository.loadStellarKeyPair()
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.interface.apply(updates: [
                    .hidePaymentConfirmation,
                    .activityIndicatorVisibility(.visible),
                    .primaryButtonEnabled(false)
                ])
            })
            .flatMap { keyPair -> Completable in
                return transaction.send(paymentOperation, sourceKeyPair: keyPair)
            }
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                Logger.shared.error("Failed to send XLM. Error: \(error)")
                let errorMessage: String
                if let stellarError = error as? StellarPaymentOperationError, stellarError == .cancelled {
                    // User cancelled transaction when shown second password - do not show an error.
                    return
                } else if let stellarError = error as? StellarServiceError, stellarError == .amountTooLow {
                    errorMessage = LocalizationConstants.Stellar.notEnoughXLM
                } else if let stellarError = error as? StellarServiceError, stellarError == .insufficientFundsForNewAccount {
                    errorMessage = LocalizationConstants.Stellar.minimumForNewAccountsError
                } else {
                    errorMessage = LocalizationConstants.Stellar.cannotSendXLMAtThisTime
                }
                
                self?.interface.apply(updates: [
                    .errorLabelText(errorMessage),
                    .errorLabelVisibility(.visible),
                    .activityIndicatorVisibility(.hidden),
                    .primaryButtonEnabled(true)
                ])
            }, onCompleted: { [weak self] in
                self?.computeMaxSpendableAmount(for: paymentOperation.sourceAccount.publicKey)
                self?.interface.apply(updates: [
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
        guard let sourceAccount = services.repository.defaultAccount else {
            interface.apply(updates: [
                .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                .errorLabelVisibility(.visible)
            ])
            return
        }

        let disposable = Single.zip(
            services.limits.isSpendable(amount: amount, for: sourceAccount.publicKey),
            services.accounts.validate(accountID: toAddress)
        ).subscribeOn(MainScheduler.asyncInstance)
        .observeOn(MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] isSpendable, isValidDestination in
            guard isSpendable else {
                self?.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Stellar.notEnoughXLM),
                    .errorLabelVisibility(.visible),
                    .fiatFieldTextColor(.error),
                    .xlmFieldTextColor(.error)
                ])
                return
            }
            guard isValidDestination else {
                self?.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Stellar.invalidDestinationAddress),
                    .errorLabelVisibility(.visible),
                    .stellarAddressTextColor(.error)
                ])
                return
            }
            let operation = StellarPaymentOperation(
                destinationAccountId: toAddress,
                amountInXlm: amount,
                sourceAccount: sourceAccount,
                feeInXlm: feeInXlm,
                memo: memo
            )
            self?.interface.apply(updates: [
                .showPaymentConfirmation(operation),
                .errorLabelVisibility(.hidden),
                .stellarAddressTextColor(.gray6)
            ])
        }, onError: { [weak self] error in
            Logger.shared.error("Could not fetch ledger or account details")
            self?.interface.apply(updates: [
                .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                .errorLabelVisibility(.visible)
            ])
        })
        disposables.insertWithDiscardableResult(disposable)
    }

    func onMinimumBalanceInfoTapped() {
        let fiatSymbol = BlockchainSettings.App.shared.fiatCurrencyCode
        let disposable = Single.zip(
            services.prices.fiatPrice(forAssetType: .stellar, fiatSymbol: fiatSymbol),
            services.ledger.current.take(1).asSingle(),
            services.accounts.currentStellarAccount(fromCache: true)
                .ifEmpty(default: StellarAccount.empty())
        ).subscribeOn(MainScheduler.asyncInstance)
        .observeOn(MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] price, ledger, account in
            guard let this = self else { return }
            this.showMinimumBalanceView(
                latestPrice: price.price,
                fee: ledger.baseFeeInXlm ?? this.services.ledger.fallbackBaseFee,
                balance: account.assetAccount.balance,
                baseReserve: ledger.baseReserveInXlm ?? this.services.ledger.fallbackBaseReserve
            )
        }, onError: { [weak self] _ in
            guard let this = self else { return }
            this.showMinimumBalanceView(
                latestPrice: 0,
                fee: this.services.ledger.fallbackBaseFee,
                balance: 0,
                baseReserve: this.services.ledger.fallbackBaseReserve
            )
        })
        disposables.insertWithDiscardableResult(disposable)
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
            baseReserve: baseReserve
        ) { viewController in
            UIApplication.shared.openSafariViewController(
                url: Constants.Url.stellarMinimumBalanceInfo,
                presentingViewController: viewController
            )
        }
        let viewController = InformationViewController.make(viewModel: viewModel)
        let navigationController = BCNavigationController(rootViewController: viewController, title: LocalizationConstants.Stellar.minimumBalance)
        interface.present(viewController: navigationController)
    }

    private func initializeActionableLabel() {
        // Initialize with 0
        interface.apply(updates: [
            .actionableLabelTrigger(ActionableTrigger(
                text: LocalizationConstants.Stellar.useSpendableBalanceX,
                CTA: "... \(AssetType.stellar.symbol)",
                executionBlock: {}
            ))
        ])
    }

    private func computeMaxSpendableAmount(for accountId: String) {
        let fiatSymbol = BlockchainSettings.App.shared.fiatCurrencyCode ?? "USD"
        let disposable = Single.zip(
            services.prices.fiatPrice(forAssetType: .stellar, fiatSymbol: fiatSymbol),
            services.limits.maxSpendableAmount(for: accountId)
        ).subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] price, maxSpendableAmount in
                let maxString = NumberFormatter.stellarFormatter.string(for: maxSpendableAmount) ?? "0"
                let trigger = ActionableTrigger(
                    text: LocalizationConstants.Stellar.useSpendableBalanceX,
                    CTA: "\(maxString) \(AssetType.stellar.symbol)",
                    executionBlock: {
                        self?.interface.apply(updates: [
                            .stellarAmountText(maxString)
                        ])
                        self?.onXLMEntry("\(maxSpendableAmount)", latestPrice: price.price)
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
            address: StellarAddress(string: ""),
            balance: 0,
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
        let assetType: AssetType = .stellar
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
