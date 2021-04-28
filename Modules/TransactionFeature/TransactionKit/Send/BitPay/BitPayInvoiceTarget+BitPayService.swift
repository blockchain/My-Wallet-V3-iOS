//
//  BitPayInvoiceTarget+BitPayService.swift
//  TransactionKit
//
//  Created by Alex McGregor on 4/8/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

enum BitPayError: Error {
    case unsupportedCurrencyType
    case invalidBitPayURL
    case invoiceError
    case invalidBitcoinURL
    case invalidBitcoinCashURL
}

extension BitPayInvoiceTarget {
    
    // MARK: - Enums
    
    private enum Prefix {
        static let bitpay = "bitpay.com"
        static let bitcoin = "bitcoin:?r="
        static let bitcoinCash = "bitcoincash:?r="
    }
    
    private enum Constants {
        static let forMerchant = "for merchant "
    }
    
    private static let bitpayService: BitPayServiceAPI = resolve()
    
    // MARK: - Public Factory
    
    public static func isBitcoin(_ data: String) -> Completable {
        Completable.fromCallable {
            guard data.contains(Prefix.bitcoin) else {
                throw BitPayError.invalidBitcoinURL
            }
        }
    }
    
    public static func isBitcoinCash(_ data: String) -> Completable {
        Completable.fromCallable {
            guard data.contains(Prefix.bitcoinCash) else {
                throw BitPayError.invalidBitcoinCashURL
            }
        }
    }
    
    public static func isSupportedAsset(_ asset: CryptoCurrency) -> Completable {
        Completable.fromCallable {
            guard asset.supportsBitPay else {
                throw BitPayError.unsupportedCurrencyType
            }
        }
    }
    
    public static func isBitPay(_ data: String) -> Completable {
        Completable.fromCallable {
            guard data.contains(Prefix.bitpay) else {
                throw BitPayError.invalidBitPayURL
            }
        }
    }
    
    public static func make(from data: String,
                            asset: CryptoCurrency) -> Single<BitPayInvoiceTarget> {
        isBitPay(data)
            .andThen(invoiceId(from: data))
            .flatMap { invoiceId in
                BitPayInvoiceTarget
                    .bitpayService
                    .getBitPayPaymentRequest(
                        invoiceID: invoiceId,
                        currency: asset
                    )
                    .map { request -> BitPayInvoiceTarget in
                        .init(asset: asset,
                              amount: .create(minor: request.outputs[0].amount, currency: asset),
                              invoiceId: invoiceId,
                              merchant: request.memo
                                .components(separatedBy: Constants.forMerchant)
                                .last ?? "",
                              address: request.outputs[0].address,
                              expires: request.expires
                        )
                    }
            }
            .do(onError: { error in
                Logger.shared.error("\(error)")
            })
    }
    
    // MARK: - Private Functions
    
    private static func invoiceId(from data: String) -> Single<String> {
        .create { observer -> Disposable in
            let payload = data
                .replacingOccurrences(of: Prefix.bitcoin, with: "")
                .replacingOccurrences(of: Prefix.bitcoinCash, with: "")
            guard let url = URL(string: payload) else {
                observer(.error(BitPayError.invoiceError))
                return Disposables.create()
            }
            observer(.success(url.lastPathComponent))
            return Disposables.create()
        }
    }
}
