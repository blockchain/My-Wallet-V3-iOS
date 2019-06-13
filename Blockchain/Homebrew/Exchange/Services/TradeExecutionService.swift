//
//  TradeExecutionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import StellarKit
import EthereumKit
import BitcoinKit
import ERC20Kit

class TradeExecutionService: TradeExecutionAPI {
    
    // MARK: Models
    
    struct XLMDependencies {
        let accounts: StellarAccountAPI
        let transactionAPI: StellarTransactionAPI
        let ledgerAPI: StellarLedgerAPI
        let repository: StellarWalletAccountRepository
        let limits: StellarTradeLimitsAPI
        
        init(xlm: XLMServiceProvider = XLMServiceProvider.shared) {
            transactionAPI = xlm.services.transaction
            ledgerAPI = xlm.services.ledger
            repository = xlm.services.repository
            accounts = xlm.services.accounts
            limits = xlm.services.limits
        }
    }
    
    struct Dependencies {
        let assetAccountRepository: AssetAccountRepository
        let feeService: FeeServiceAPI
        let xlm: XLMDependencies
        private let paxServiceProvider: PAXServiceProvider
        
        var erc20Service: ERC20Service<PaxToken> {
            return paxServiceProvider.services.paxService
        }
        
        var erc20AccountRepository: ERC20AssetAccountRepository<PaxToken> {
            return paxServiceProvider.services.assetAccountRepository
        }
        
        var ethereumWalletService: EthereumWalletServiceAPI {
            return paxServiceProvider.services.walletService
        }
        
        init(
            repository: AssetAccountRepository = AssetAccountRepository.shared,
            cryptoFeeService: FeeServiceAPI = FeeService.shared,
            xlmServiceProvider: XLMServiceProvider = XLMServiceProvider.shared,
            serviceProvider: PAXServiceProvider = PAXServiceProvider.shared
        ) {
            assetAccountRepository = repository
            feeService = cryptoFeeService
            xlm = XLMDependencies(xlm: xlmServiceProvider)
            self.paxServiceProvider = serviceProvider
        }
    }
    
    private struct PathComponents {
        let components: [String]
        
        static let trades = PathComponents(
            components: ["trades"]
        )
    }
    
    // MARK: Private Properties
    
    private let authentication: NabuAuthenticationService
    private let wallet: Wallet
    private let assetAccountRepository: AssetAccountRepository
    private let dependencies: Dependencies
    private let disposables = CompositeDisposable()
    private let bag: DisposeBag = DisposeBag()
    private var pendingXlmPaymentOperation: StellarPaymentOperation?
    private var ethereumTransactionCandidate: EthereumTransactionCandidate?
    
    private var bitcoinTransactionFee: Single<BitcoinTransactionFee> {
        return dependencies.feeService.bitcoin
    }
    
    private var ethereumTransactionFee: Single<EthereumTransactionFee> {
        return dependencies.feeService.ethereum
    }
    
    private var stellarTransactionFee: Single<StellarTransactionFee> {
        return dependencies.feeService.stellar
    }
    
    // MARK: TradeExecutionAPI
    
    var isExecuting: Bool = false

    func canTradeAssetType(_ assetType: AssetType) -> Bool {
        switch assetType {
        case .ethereum, .pax:
            return !wallet.isWaitingOnEtherTransaction()
        default:
            return true
        }
    }
    
    func validateVolume(_ volume: Decimal, for assetAccount: AssetAccount) -> Single<TradeExecutionAPIError?> {
        let assetType = assetAccount.address.assetType
        switch assetType {
        case .stellar:
            return validateXlm(volume: volume, for: assetAccount)
        case .pax:
            return validatePax(volume: volume, for: assetAccount)
        case .bitcoin,
             .bitcoinCash,
             .ethereum:
            return Single.just(nil)
        }
    }
    
    private func validatePax(volume: Decimal, for assetAccount: AssetAccount) -> Single<TradeExecutionAPIError?> {
        let value = CryptoValue.createFromMajorValue(volume, assetType: .pax)
        do {
            let tokenValue = try ERC20TokenValue<PaxToken>(crypto: value)
            return dependencies.erc20Service.evaluate(amount: tokenValue)
                .flatMap { _ -> Single<TradeExecutionAPIError?> in
                    Single.just(nil)
                }
                .catchError { error -> Single<TradeExecutionAPIError?> in
                    if let error = error as? ERC20ServiceError {
                        return Single.just(TradeExecutionAPIError.erc20Error(error))
                    }
                    throw error
                }
        } catch {
            return Single.error(error)
        }
    }

    private func validateXlm(volume: Decimal, for assetAccount: AssetAccount) -> Single<TradeExecutionAPIError?> {
        let accountId = assetAccount.address.address
        let isSpendable = dependencies.xlm.limits.isSpendable(amount: volume, for: accountId)
        let max = dependencies.xlm.limits.maxSpendableAmount(for: accountId)
        return Single.zip(isSpendable, max)
            .catchError { error -> Single<(Bool, Decimal)> in
                if let stellarError = error as? StellarServiceError, stellarError == StellarServiceError.noDefaultAccount {
                    return Single.just((false, 0))
                }
                throw error
            }
            .flatMap { isSpendable, maxSpendable -> Single<TradeExecutionAPIError?> in
                guard !isSpendable else {
                    return Single.just(nil)
                }
                
                let crytpo = CryptoValue.createFromMajorValue(maxSpendable, assetType: .stellar)
                return Single.error(TradeExecutionAPIError.exceededMaxVolume(crytpo))
            }
    }
    
    // MARK: Init
    
    init(
        service: NabuAuthenticationService = NabuAuthenticationService.shared,
        wallet: Wallet = WalletManager.shared.wallet,
        dependencies: Dependencies
        ) {
        self.authentication = service
        self.wallet = wallet
        self.dependencies = dependencies
        self.assetAccountRepository = dependencies.assetAccountRepository
    }
    
    deinit {
        disposables.dispose()
    }
    
    // MARK: - Main Functions

    // Pre-build an order with Exchange information to get fee information.
    // The result of this method is used for display purposes.
    // Do not use this for actually building an order to send - use
    // buildAndSend(with conversion...) instead.
    func prebuildOrder(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((String) -> Void)
    ) {
        guard let pair = TradingPair(string: conversion.quote.pair) else {
            error(LocalizationConstants.Exchange.tradeExecutionError)
            Logger.shared.error("Invalid pair returned from server: \(conversion.quote.pair)")
            return
        }
        guard pair.from == from.address.assetType,
            pair.to == to.address.assetType else {
                error(LocalizationConstants.Exchange.tradeExecutionError)
                Logger.shared.error("Asset types don't match.")
                return
        }
        // This is not the real 'to' address because an order has not been submitted yet
        // but this placeholder is needed to build the payment so that
        // the fees can be returned and displayed by the view.
        let placeholderAddress = from.address.address
        let currencyRatio = conversion.quote.currencyRatio
        let orderTransactionLegacy = OrderTransactionLegacy(
            legacyAssetType: pair.from.legacy,
            from: from.index,
            to: placeholderAddress,
            amount: currencyRatio.base.crypto.value,
            fees: nil,
            gasLimit: nil
        )
        let createOrderCompletion: ((OrderTransactionLegacy) -> Void) = { orderTransactionLegacy in
            let orderTransactionTo = AssetAddressFactory.create(
                fromAddressString: orderTransactionLegacy.to,
                assetType: AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
            )
            let orderTransaction = OrderTransaction(
                orderIdentifier: "",
                destination: to,
                from: from,
                to: orderTransactionTo,
                amountToSend: orderTransactionLegacy.amount,
                amountToReceive: currencyRatio.counter.crypto.value,
                fees: orderTransactionLegacy.fees!
            )
            success(orderTransaction, conversion)
        }
        
        buildOrder(
            from: orderTransactionLegacy,
            success: createOrderCompletion,
            error: { (message, transactionID, nabuNetworkError) in
                error(message)
        })
    }
    
    func trackTransactionFailure(_ reason: String, transactionID: String, completion: @escaping (Error?) -> Void) {
        guard let baseURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            completion(TradeExecutionAPIError.generic)
            return
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["trades", transactionID, "failure-reason"],
            queryParameters: nil
            ) else {
                completion(TradeExecutionAPIError.generic)
                return
        }
        
        let payload = TransactionFailure(message: reason)
        
        let disposable = authentication.getSessionToken()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] token in
                guard let this = self else { return }
                let disposable = NetworkRequest.PUT(url: endpoint,
                                                    body: try? JSONEncoder().encode(payload),
                                                    headers: [HttpHeaderField.authorization: token.token])
                    .subscribeOn(MainScheduler.asyncInstance)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onCompleted: {
                        completion(nil)
                    }, onError: { error in
                        completion(error)
                    })
            
            this.disposables.insertWithDiscardableResult(disposable)
        }, onError: { error in
            completion(error)
        })
        
        disposables.insertWithDiscardableResult(disposable)
    }

    // Build an order from an OrderTransactionLegacy struct.
    // OrderTransactionLegacy is a representation of a regular payment object
    // that has no Exchange information.
    fileprivate func buildOrder(
        from orderTransactionLegacy: OrderTransactionLegacy,
        transactionID: TransactionID? = nil,
        success: @escaping ((OrderTransactionLegacy) -> Void),
        error: @escaping ((ErrorMessage, TransactionID?, NabuNetworkError?) -> Void),
        memo: String? = nil // TODO: IOS-1291 Remove and separate
    ) {
        let assetType = AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
        let createOrderPaymentSuccess: ((String) -> Void) = { fees in
            if assetType == .bitcoin || assetType == .bitcoinCash {
                // TICKET: IOS-1395 - Use a helper method for this
                let feeInSatoshi = CUnsignedLongLong(truncating: NSDecimalNumber(string: fees))
                orderTransactionLegacy.fees = NumberFormatter.satoshi(toBTC: feeInSatoshi)
            } else {
                orderTransactionLegacy.fees = fees
            }
            success(orderTransactionLegacy)
        }

        // TICKET: IOS-1550 Move this to a different service
        if assetType == .stellar {
            let disposable = stellarTransactionFee.asObservable()
                .catchErrorJustReturn(.default)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] stellarFee in
                    guard let self = self else { return }
                    
                    guard let sourceAccount = self.dependencies.xlm.repository.defaultAccount,
                        let ledger = self.dependencies.xlm.ledgerAPI.currentLedger,
                        let amount = Decimal(string: orderTransactionLegacy.amount) else { return }
                    
                    var paymentMemo: StellarMemoType?
                    if let value = memo {
                        paymentMemo = .text(value)
                    }
                    
                    let fee = stellarFee.regular.majorValue
                    
                    self.pendingXlmPaymentOperation = StellarPaymentOperation(
                        destinationAccountId: orderTransactionLegacy.to,
                        amountInXlm: amount,
                        sourceAccount: sourceAccount,
                        feeInXlm: fee,
                        memo: paymentMemo
                    )
                    createOrderPaymentSuccess("\(fee)")
                })
            disposables.insertWithDiscardableResult(disposable)
        } else if assetType == .pax {
            guard
                let cryptoValue = CryptoValue.paxFromMajor(string: orderTransactionLegacy.amount),
                let tokenValue = try? ERC20TokenValue<PaxToken>.init(crypto: cryptoValue),
                let address = EthereumAccountAddress(rawValue: orderTransactionLegacy.to)?.ethereumAddress
            else {
                return
            }
            dependencies.erc20Service.evaluate(amount: tokenValue)
                .subscribeOn(MainScheduler.instance)
                .observeOn(MainScheduler.asyncInstance)
                .flatMap(weak: self, { (self, _) -> Single<EthereumTransactionCandidate> in
                    return self.dependencies.erc20Service.transfer(to: address, amount: tokenValue)
                })
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] candidate in
                    guard let self = self else { return }
                    self.ethereumTransactionCandidate = candidate
                    let feeAmount = candidate.gasLimit * candidate.gasPrice
                    let wei = CryptoValue.etherFromWei(string: "\(feeAmount)")
                    createOrderPaymentSuccess(wei?.toDisplayString(includeSymbol: false) ?? "1234")
                }, onError: { erc20Error in
                    // TODO: Better error messaging
                    if let erc20Error = erc20Error as? ERC20ServiceError {
                        let internalError = SendMoniesInternalError(erc20error: erc20Error)
                        error(internalError.description ?? LocalizationConstants.Errors.genericError, nil, nil)
                    } else {
                        error(LocalizationConstants.Errors.genericError, nil, nil)
                    }
                    Logger.shared.error(erc20Error)
                })
                .disposed(by: bag)
        } else {
            let disposable = Observable.zip(
                    bitcoinTransactionFee.asObservable(),
                    ethereumTransactionFee.asObservable()
                )
                /// Should either transaction fee fetches fail, we fall back to
                /// default fee models.
                .catchErrorJustReturn((.default, .default))
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (bitcoinFee, ethereumFee) in
                    guard let self = self else { return }
                    switch assetType {
                    case .bitcoin,
                         .bitcoinCash:
                        orderTransactionLegacy.fees = bitcoinFee.priority.toDisplayString(includeSymbol: false)
                    case .ethereum:
                        orderTransactionLegacy.fees = ethereumFee.priorityGweiValue
                        orderTransactionLegacy.gasLimit = String(ethereumFee.gasLimit)
                    case .stellar, .pax:
                        break
                    }
                    
                    self.wallet.createOrderPayment(
                        withOrderTransaction: orderTransactionLegacy,
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.isExecuting = false
                        }, success: createOrderPaymentSuccess,
                           error: { errorMessage in
                            error(errorMessage, transactionID, nil)
                    })
                    }, onError: { networkError in
                      error(networkError.localizedDescription, nil, nil)
                })
            disposables.insertWithDiscardableResult(disposable)
        }
    }

    // Post a trade to the server. This will create a trade object that will
    // be seen in the ExchangeListViewController.
    fileprivate func process(order: Order) -> Single<OrderResult> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(TradeExecutionAPIError.generic)
        }

        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: PathComponents.trades.components,
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }

        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.POST(
                url: endpoint,
                body: try? JSONEncoder().encode(order),
                type: OrderResult.self,
                headers: [HttpHeaderField.authorization: token.token]
            )
        }
    }

    // Sign and send the payment object created by either of the buildOrder methods.
    fileprivate func sendTransaction(
        assetType: AssetType,
        transactionID: String?,
        secondPassword: String?,
        keyPair: StellarKeyPair?,
        success: @escaping (() -> Void),
        error: @escaping ((ErrorMessage, TransactionID?, NabuNetworkError?) -> Void)
    ) {
        let executionDone = { [weak self] in
            guard let this = self else { return }
            this.isExecuting = false
        }
        if assetType == .stellar {
            guard let paymentOperation = pendingXlmPaymentOperation else {
                Logger.shared.error("No pending payment operation found")
                return
            }
            guard let pair = keyPair as? StellarKeyPair else {
                Logger.shared.error("No KeyPair provided")
                return
            }
            
            let transaction = dependencies.xlm.transactionAPI
            let disposable = Single.just(pair)
                .asObservable().flatMap { keyPair -> Completable in
                    return transaction.send(paymentOperation, sourceKeyPair: keyPair)
                }.subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onError: { paymentError in
                    executionDone()
                    Logger.shared.error("Failed to send XLM. Error: \(paymentError)")
                    var message = LocalizationConstants.Stellar.cannotSendXLMAtThisTime
                    if let serviceError = paymentError as? StellarServiceError {
                        message = serviceError.message
                    }
                    error(
                        message,
                        transactionID,
                        paymentError as? NabuNetworkError
                    )
                }, onCompleted: {
                    executionDone()
                    success()
                })
            disposables.insertWithDiscardableResult(disposable)
        } else if assetType == .pax {
            guard let candidate = ethereumTransactionCandidate else {
                Logger.shared.error("No EthereumTransactionCandidate")
                return
            }
            
            dependencies.ethereumWalletService.send(transaction: candidate)
                .subscribeOn(MainScheduler.instance)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onSuccess: { published in
                    executionDone()
                    success()
                }, onError: { ethereumError in
                    executionDone()
                    Logger.shared.error("Failed to send PAX. Error: \(ethereumError)")
                    error(
                        LocalizationConstants.Errors.genericError,
                        transactionID,
                        ethereumError as? NabuNetworkError
                    )
                })
                .disposed(by: bag)
        } else {
            isExecuting = true
            wallet.sendOrderTransaction(
                assetType.legacy,
                secondPassword: secondPassword,
                completion: executionDone,
                success: success,
                error: { message in
                    error(message, transactionID, nil)
            },
                cancel: executionDone
            )
        }
    }
}

// Private Helper methods
fileprivate extension TradeExecutionService {
    // Method for combining process and build order.
    // Called by buildAndSend(with conversion...)
    //
    // TICKET: IOS-1291 Refactor this
    // swiftlint:disable function_body_length
    func processAndBuildOrder(
        with conversion: Conversion,
        fromAccount: AssetAccount,
        toAccount: AssetAccount,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((ErrorMessage, TransactionID?, NabuNetworkError?) -> Void)
    ) {
        isExecuting = true
        let conversionQuote = conversion.quote
        #if DEBUG
        let settings = DebugSettings.shared
        if settings.mockExchangeDeposit {
            settings.mockExchangeDepositQuantity = conversionQuote.fix == .base ||
                conversionQuote.fix == .baseInFiat ?
                    conversionQuote.currencyRatio.base.crypto.value :
                conversionQuote.currencyRatio.counter.crypto.value
            settings.mockExchangeDepositAssetTypeString = TradingPair(string: conversionQuote.pair)!.from.symbol
        }
        #endif
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let time = dateFormatter.string(from: Date())
        let quote = Quote(
            time: time,
            pair: conversionQuote.pair,
            fiatCurrency: conversionQuote.fiatCurrency,
            fix: conversionQuote.fix,
            volume: conversionQuote.volume,
            currencyRatio: conversionQuote.currencyRatio
        )
        let refund = getReceiveAddress(for: fromAccount.index, assetType: fromAccount.address.assetType)
        let destination = getReceiveAddress(for: toAccount.index, assetType: toAccount.address.assetType)
        
        Maybe.zip(refund, destination)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self, { (self, tuple) -> Single<Order> in
                let refundAddress = tuple.0
                let destinationAddress = tuple.1
                return Single.just(Order(
                    destinationAddress: destinationAddress,
                    refundAddress: refundAddress,
                    quote: quote
                ))
            })
            .flatMap { order -> Single<OrderResult> in
                return self.process(order: order)
            }
            .subscribe(onSuccess: { [weak self] payload in
                guard let this = self else { return }
                // Here we should have an OrderResult object, with a deposit address.
                // Fees must be fetched from wallet payment APIs
                let createOrderCompletion: ((OrderTransactionLegacy) -> Void) = { orderTransactionLegacy in
                    let assetType = AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
                    let to = AssetAddressFactory.create(fromAddressString: orderTransactionLegacy.to, assetType: assetType)
                    let orderTransaction = OrderTransaction(
                        orderIdentifier: payload.id,
                        destination: toAccount,
                        from: fromAccount,
                        to: to,
                        amountToSend: orderTransactionLegacy.amount,
                        amountToReceive: payload.withdrawal.value,
                        fees: orderTransactionLegacy.fees!
                    )
                    success(orderTransaction, conversion)
                }
                this.buildOrderFrom(orderResult: payload, fromAccount: fromAccount, success: createOrderCompletion, error: error)
            }, onError: { [weak self] requestError in
                guard let this = self else { return }
                this.isExecuting = false
                if let nabuError = requestError as? NabuNetworkError {
                    error(requestError.localizedDescription, nil, nabuError)
                    return
                }
                guard let httpRequestError = requestError as? HTTPRequestError else {
                    error(requestError.localizedDescription, nil, nil)
                    return
                }
                error(httpRequestError.debugDescription, nil, nil)
            })
            .disposed(by: bag)
    }
    // swiftlint:enable function_body_length

    // Private helper method for building an order from an OrderResult struct (returned from the trades endpoint).
    // This method is called by the processAndBuildOrder(with conversion...) method
    // and calls buildOrder(from orderTransactionLegacy...)
    func buildOrderFrom(
        orderResult: OrderResult,
        fromAccount: AssetAccount,
        success: @escaping ((OrderTransactionLegacy) -> Void),
        error: @escaping ((ErrorMessage, TransactionID?, NabuNetworkError?) -> Void)
        ) {
        #if DEBUG
        let settings = DebugSettings.shared
        let depositAddress = settings.mockExchangeOrderDepositAddress ?? orderResult.depositAddress
        let depositQuantity = settings.mockExchangeDeposit ? settings.mockExchangeDepositQuantity! : orderResult.deposit.value
        let assetType = settings.mockExchangeDeposit ?
            AssetType(stringValue: settings.mockExchangeDepositAssetTypeString!)!
            : TradingPair(string: orderResult.pair)!.from
        #else
        let depositAddress = orderResult.depositAddress
        let depositQuantity = orderResult.deposit.value
        let pair = TradingPair(string: orderResult.pair)
        let assetType = pair!.from
        #endif
        guard assetType == fromAccount.address.assetType else {
            error("AssetType from fromAccount and AssetType from OrderResult do not match", orderResult.id, nil)
            return
        }
        
        let orderTransactionLegacy = OrderTransactionLegacy(
            legacyAssetType: fromAccount.address.assetType.legacy,
            from: fromAccount.index,
            to: depositAddress,
            amount: depositQuantity,
            fees: nil,
            gasLimit: nil
        )
        
        let disposable = Observable.zip(
                bitcoinTransactionFee.asObservable(),
                ethereumTransactionFee.asObservable()
            )
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (bitcoinFee, ethereumFee) in
                guard let self = self else { return }
                switch assetType {
                case .bitcoin,
                     .bitcoinCash:
                    orderTransactionLegacy.fees = bitcoinFee.priority.toDisplayString(includeSymbol: false)
                case .ethereum:
                    orderTransactionLegacy.fees = ethereumFee.priorityGweiValue
                    orderTransactionLegacy.gasLimit = String(ethereumFee.gasLimit)
                case .stellar, .pax:
                    break
                }
                
                self.buildOrder(
                    from: orderTransactionLegacy,
                    transactionID: orderResult.id,
                    success: success,
                    error: error,
                    memo: orderResult.depositMemo
                )
            }, onError: { networkError in
                error(networkError.localizedDescription, nil, nil)
            })
        disposables.insertWithDiscardableResult(disposable)
    }
}

// TradeExecutionAPI Helper Functions
extension TradeExecutionService {
    // Public helper method for combining processAndBuildOrder and sendTransaction.
    // Used as the final step to convert Exchange information into built payment
    // and immediately sending the order.
    func buildAndSend(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping ((OrderTransaction) -> Void),
        error: @escaping ((ErrorMessage, TransactionID?, NabuNetworkError?) -> Void)
    ) {
        /// This is not great but, `TradeExecutionService` is likely to be broken
        /// up and refactored in the future. The `String` is the secondary password.
        /// Not all users have one. The `KeyPair` is, at the moment, for XLM only.
        let processAndBuild: ((String?, StellarKeyPair?) -> ()) = { [weak self] secondPassword, pair in
            guard let this = self else { return }
            if secondPassword != nil && pair != nil {
                Logger.shared.warning("You shouldn't need to provide a secondary password if you have the keyPair.")
            }
            this.processAndBuildOrder(
                with: conversion,
                fromAccount: from,
                toAccount: to,
                success: { [weak self] orderTransaction, _ in
                    guard let this = self else { return }
                    this.sendTransaction(
                        assetType: orderTransaction.to.assetType,
                        transactionID: orderTransaction.orderIdentifier,
                        secondPassword: secondPassword,
                        keyPair: pair,
                        success: {
                            success(orderTransaction)
                        },
                        error: error
                    )
                },
                error: error
            )
        }
        
        let secondaryPasswordRequired = wallet.needsSecondPassword()
        
        let loadXLMKeyPair = {
            /// `loadKeyPair()` will trigger a prompt for the user to enter their
            /// secondary password
            let disposable = self.dependencies.xlm.repository.loadKeyPair()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { keyPair in
                    processAndBuild(nil, keyPair)
                }, onError: { output in
                    error(LocalizationConstants.Authentication.secondPasswordIncorrect, nil, nil)
                })
            self.disposables.insertWithDiscardableResult(disposable)
        }
        
        // Second password must be prompted before an order is processed since it is
        // a cancellable action - otherwise an order will be created even if cancelling
        // second password
        if from.address.assetType == .stellar {
            loadXLMKeyPair()
        } else if secondaryPasswordRequired {
            AuthenticationCoordinator.shared.showPasswordConfirm(
                withDisplayText: LocalizationConstants.Authentication.secondPasswordDefaultDescription,
                headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                validateSecondPassword: true,
                confirmHandler: { (secondPass) in
                    processAndBuild(secondPass, nil)
            },
                dismissHandler: {
                    error(LocalizationConstants.Authentication.secondPasswordIncorrect, nil, nil)
            })
        } else {
            processAndBuild(nil, nil)
        }
    }
}

private extension TradeExecutionService {
    func getReceiveAddress(for account: Int32, assetType: AssetType) -> Maybe<String> {
        if assetType == .stellar {
            guard let address = assetAccountRepository.defaultStellarAccount()?.address.address else { return Maybe.empty() }
            return Maybe.just(address)
        }
        if assetType == .pax {
            return dependencies.erc20AccountRepository.assetAccountDetails.flatMap { details -> Maybe<String> in
                return Maybe.just(details.account.accountAddress)
            }
        }
        return Maybe.just(wallet.getReceiveAddress(forAccount: account, assetType: assetType.legacy))
    }
}
