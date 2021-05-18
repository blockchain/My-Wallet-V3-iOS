//
//  LegacyWalletAPI.swift
//  Blockchain
//
//  Created by Jack on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class OrderTransactionLegacy: NSObject {
    @objc let legacyAssetType: LegacyAssetType
    @objc let from: Int32
    @objc let to: String
    @objc let amount: String
    @objc var fees: String?
    @objc var gasLimit: String?

    init(
        legacyAssetType: LegacyAssetType,
        from: Int32,
        to: String,
        amount: String,
        fees: String?,
        gasLimit: String?
    ) {
        self.legacyAssetType = legacyAssetType
        self.from = from
        self.to = to
        self.amount = amount
        self.fees = fees
        self.gasLimit = gasLimit
        super.init()
    }
}

protocol LegacyWalletAPI: AnyObject {

    func updateAccountLabel(
        _ cryptoCurrency: CryptoCurrency,
        index: Int,
        label: String
    ) -> Completable

    func createOrderPayment(withOrderTransaction orderTransaction: OrderTransactionLegacy,
                            completion: @escaping () -> Void,
                            success: @escaping ([AnyHashable: Any]) -> Void,
                            error: @escaping ([AnyHashable: Any]) -> Void)
    
    func sendOrderTransaction(_ legacyAssetType: LegacyAssetType,
                              secondPassword: String?,
                              completion: @escaping () -> Void,
                              success: @escaping (String) -> Void,
                              error: @escaping (String) -> Void,
                              cancel: @escaping () -> Void)
    
    func needsSecondPassword() -> Bool
    
    func getReceiveAddress(forAccount account: Int32,
                           assetType: LegacyAssetType) -> String!
}

extension Wallet: LegacyWalletAPI {}
