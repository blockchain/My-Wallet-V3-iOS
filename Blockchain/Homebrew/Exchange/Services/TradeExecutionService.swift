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
        
        static let limits = PathComponents(
            components: ["trades", "limits"]
        )
    }
    
    private let authentication: NabuAuthenticationService
    private let wallet: Wallet
    private var disposable: Disposable?
    
    init(service: NabuAuthenticationService = NabuAuthenticationService.shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.authentication = service
        self.wallet = wallet
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: TradeExecutionAPI
    
    func getTradeLimits(withCompletion: @escaping ((Result<TradeLimits>) -> Void)) {
        disposable = limits()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (payload) in
                withCompletion(.success(payload))
            }, onError: { error in
                withCompletion(.error(error))
            })
    }

    // TICKET: IOS-1291 Refactor this
    func submitOrder(
        with conversion: Conversion,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((String) -> Void)
    ) {
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
        let pair = TradingPair(string: quote.pair)!
        let refundAddress = wallet.getReceiveAddress(ofDefaultAccount: pair.from.legacy)
        let destinationAddress = wallet.getReceiveAddress(ofDefaultAccount: pair.to.legacy)
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
                    let fromAddress = AssetAddressFactory.create(fromAddressString: addressString!, assetType: assetType)
                    let to = AssetAddressFactory.create(fromAddressString: orderTransactionLegacy.to, assetType: assetType)
                    let orderTransaction = OrderTransaction(
                        from: AssetAccount(
                            index: 0,
                            address: fromAddress,
                            balance: NSDecimalNumber(string: orderTransactionLegacy.amount).decimalValue,
                            name: "assetAccount"
                        ),
                        to: to,
                        amountToSend: orderTransactionLegacy.amount,
                        amountToReceive: payload.withdrawalQuantity,
                        fees: orderTransactionLegacy.fees!
                    )
                    success(orderTransaction, conversion)
                }
                this.createOrder(from: payload, success: createOrderCompletion, error: error)
        })
        // Can't figure out error: Extra argument 'onError' in call
//        , onError: { error in
//            withCompletion(.error(error))
//        })
    }

    func sendTransaction(assetType: AssetType, success: @escaping (() -> Void), error: @escaping ((String) -> Void)) {
        wallet.sendOrderTransaction(assetType.legacy, success: success, error: error)
    }

    func submitAndSend(
        with conversion: Conversion,
        success: @escaping (() -> Void),
        error: @escaping ((String) -> Void)
    ) {
        submitOrder(with: conversion, success: { [weak self] orderTransaction, conversion in
            guard let this = self else { return }
            this.sendTransaction(assetType: orderTransaction.to.assetType, success: success, error: error)
        }, error: error)
    }
    // MARK: Private
    
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
    
    fileprivate func createOrder(
        from orderResult: OrderResult,
        success: @escaping ((OrderTransactionLegacy) -> Void),
        error: @escaping ((String) -> Void)
    ) {
        #if DEBUG
        let settings = DebugSettings.shared
        let depositAddress = settings.mockExchangeOrderDepositAddress ?? orderResult.depositAddress
        let depositQuantity = settings.mockExchangeDeposit ? settings.mockExchangeDepositQuantity! : orderResult.depositQuantity
        let assetType = settings.mockExchangeDeposit ?
            AssetType(stringValue: settings.mockExchangeDepositAssetTypeString!)!
            : TradingPair(string: orderResult.pair)!.from
        #else
        let depositAddress = orderResult.depositAddress!
        let depositQuantity = orderResult.depositQuantity!
        let pair = TradingPair(string: orderResult.pair!)
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
        let createOrderPaymentSuccess: ((String) -> Void) = { fees in
            if assetType == .bitcoin || assetType == .bitcoinCash {
                let feeInSatoshi = CUnsignedLongLong(truncating: NSDecimalNumber(string: fees))
                orderTransactionLegacy.fees = NumberFormatter.satoshi(toBTC: feeInSatoshi)
            } else {
                orderTransactionLegacy.fees = fees
            }
            success(orderTransactionLegacy)
        }
        wallet.createOrderPayment(withOrderTransaction: orderTransactionLegacy, success: createOrderPaymentSuccess, error: error)
    }

    fileprivate func limits() -> Single<TradeLimits> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: PathComponents.limits.components,
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                token: token.token,
                type: TradeLimits.self
            )
        }
    }
}
