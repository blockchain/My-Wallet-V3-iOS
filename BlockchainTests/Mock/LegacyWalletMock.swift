//
//  LegacyWalletMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
@testable import Blockchain

class LegacyWalletMock: LegacyWalletAPI {

    var password: String?

    func createOrderPayment(withOrderTransaction orderTransaction: OrderTransactionLegacy,
                            completion: @escaping () -> Void,
                            success: @escaping ([AnyHashable : Any]) -> Void,
                            error: @escaping ([AnyHashable : Any]) -> Void) {
        success([:])
        completion()
    }
    
    func sendOrderTransaction(
        _ legacyAssetType: LegacyAssetType,
        secondPassword: String?,
        completion: @escaping () -> Void,
        success: @escaping (String) -> Void,
        error: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        success("")
        completion()
    }
    
    func needsSecondPassword() -> Bool {
        false
    }
    
    func getReceiveAddress(forAccount account: Int32, assetType: LegacyAssetType) -> String! {
        ""
    }

    func updateAccountLabel(_ cryptoCurrency: CryptoCurrency, index: Int, label: String) -> Completable {
        .empty()
    }
}
