//
//  TradeExecutionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class TradeExecutionService: TradeExecutionAPI {
    
    enum TradeExecutionAPIError: Error {
        case generic
    }
    
    private struct PathComponents {
        let components: [String]
        
        static let trades = PathComponents(
            components: ["trades"]
        )
    }
    
    private let authentication: NabuAuthenticationService
    private let wallet: Wallet
    private var disposable: Disposable?
    
    // MARK: TradeExecutionAPI
    
    var isExecuting: Bool = false
    
    init(service: NabuAuthenticationService = NabuAuthenticationService.shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.authentication = service
        self.wallet = wallet
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: TradeExecutionAPI Functions

    func buildOrder(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((String) -> Void)
    ) {
        guard let pair = TradingPair(string: conversion.quote.pair) else {
            error("Invalid pair returned from server: \(conversion.quote.pair)")
            return
        }
        guard pair.from == from.address.assetType,
            pair.to == to.address.assetType else {
            error("Asset types don't match.")
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
            fees: nil
        )
        let createOrderCompletion: ((OrderTransactionLegacy) -> Void) = { orderTransactionLegacy in
            let orderTransactionTo = AssetAddressFactory.create(
                fromAddressString: orderTransactionLegacy.to,
                assetType: AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
            )
            let orderTransaction = OrderTransaction(
                destination: to,
                from: from,
                to: orderTransactionTo,
                amountToSend: orderTransactionLegacy.amount,
                amountToReceive: currencyRatio.counter.crypto.value,
                fees: orderTransactionLegacy.fees!
            )
            success(orderTransaction, conversion)
        }
        buildOrder(from: orderTransactionLegacy, success: createOrderCompletion, error: error)
    }

    func buildAndSend(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping (() -> Void),
        error: @escaping ((String) -> Void)
    ) {
        isExecuting = true
        buildAndSendOrder(
            with: conversion,
            fromAccount: from,
            toAccount: to,
            success: { [weak self] orderTransaction, conversion in
                guard let this = self else { return }
                this.sendTransaction(assetType: orderTransaction.to.assetType, success: success, error: error)
            },
            error: error
        )
    }
    // MARK: Private

    // TICKET: IOS-1291 Refactor this
    // swiftlint:disable function_body_length
    fileprivate func buildAndSendOrder(
        with conversion: Conversion,
        fromAccount: AssetAccount,
        toAccount: AssetAccount,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((String) -> Void)
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
        let refundAddress = wallet.getReceiveAddress(forAccount: fromAccount.index, assetType: fromAccount.address.assetType.legacy)
        let destinationAddress = wallet.getReceiveAddress(forAccount: toAccount.index, assetType: toAccount.address.assetType.legacy)
        let order = Order(
            destinationAddress: destinationAddress!,
            refundAddress: refundAddress!,
            quote: quote
        )
        disposable = process(order: order)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] payload in
                guard let this = self else { return }
                // Here we should have an OrderResult object, with a deposit address.
                // Fees must be fetched from wallet payment APIs
                let createOrderCompletion: ((OrderTransactionLegacy) -> Void) = { [weak self] orderTransactionLegacy in
                    guard let this = self else { return }
                    let addressString = this.wallet.getReceiveAddress(forAccount: 0, assetType: orderTransactionLegacy.legacyAssetType)
                    let assetType = AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
                    let to = AssetAddressFactory.create(fromAddressString: orderTransactionLegacy.to, assetType: assetType)
                    let orderTransaction = OrderTransaction(
                        destination: toAccount,
                        from: fromAccount,
                        to: to,
                        amountToSend: orderTransactionLegacy.amount,
                        amountToReceive: payload.withdrawal.value,
                        fees: orderTransactionLegacy.fees!
                    )
                    success(orderTransaction, conversion)
                }
                this.buildOrder(from: payload, success: createOrderCompletion, error: error)
            }, onError: { [weak self] requestError in
                    guard let this = self else { return }
                    this.isExecuting = false
                    guard let httpRequestError = requestError as? HTTPRequestError else {
                        error(requestError.localizedDescription)
                        return
                    }
                    error(httpRequestError.debugDescription)
            })
    }
    // swiftlint:enable function_body_length

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
                token: token.token,
                type: OrderResult.self
            )
        }
    }
    
    fileprivate func buildOrder(
        from orderResult: OrderResult,
        success: @escaping ((OrderTransactionLegacy) -> Void),
        error: @escaping ((String) -> Void)
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
        let legacyAssetType = assetType.legacy
        let orderTransactionLegacy = OrderTransactionLegacy(
            legacyAssetType: legacyAssetType,
            from: wallet.getDefaultAccountIndex(for: legacyAssetType),
            to: depositAddress,
            amount: depositQuantity,
            fees: nil
        )
        buildOrder(from: orderTransactionLegacy, success: success, error: error)
    }

    fileprivate func buildOrder(
        from orderTransactionLegacy: OrderTransactionLegacy,
        success: @escaping ((OrderTransactionLegacy) -> Void),
        error: @escaping ((String) -> Void)
    ) {
        let assetType = AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
        let createOrderPaymentSuccess: ((String) -> Void) = { fees in
            if assetType == .bitcoin || assetType == .bitcoinCash {
                let feeInSatoshi = CUnsignedLongLong(truncating: NSDecimalNumber(string: fees))
                orderTransactionLegacy.fees = NumberFormatter.satoshi(toBTC: feeInSatoshi)
            } else {
                orderTransactionLegacy.fees = fees
            }
            success(orderTransactionLegacy)
        }
        wallet.createOrderPayment(
            withOrderTransaction: orderTransactionLegacy,
            completion: { [weak self] in
                guard let this = self else { return }
                this.isExecuting = false
            },
            success: createOrderPaymentSuccess,
            error: error
        )
    }

    fileprivate func sendTransaction(assetType: AssetType, success: @escaping (() -> Void), error: @escaping ((String) -> Void)) {
        isExecuting = true
        let executionDone = { [weak self] in
            guard let this = self else { return }
            this.isExecuting = false
        }
        wallet.sendOrderTransaction(
            assetType.legacy,
            completion: executionDone,
            success: success,
            error: error,
            cancel: executionDone
        )
    }
}
