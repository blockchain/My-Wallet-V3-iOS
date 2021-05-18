//
//  TargetSelectionInteractor.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 2/25/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class TargetSelectionInteractor {
    
    private let coincore: Coincore
    
    init(coincore: Coincore = resolve()) {
        self.coincore = coincore
    }
    
    func getAvailableTargetAccounts(sourceAccount: BlockchainAccount,
                                    action: AssetAction) -> Single<[SingleAccount]> {
        Single.just(sourceAccount)
            .map { (account) -> CryptoAccount in
                guard let crypto = account as? CryptoAccount else {
                    fatalError("Expected CryptoAccount: \(account)")
                }
                return crypto
            }
            .flatMap(weak: self) { (self, account) -> Single<[SingleAccount]> in
                self.coincore.getTransactionTargets(sourceAccount: account, action: action)
            }
    }

    func validateCrypto(address: String, account: CryptoAccount) -> Single<Result<ReceiveAddress, Error>> {
        guard let asset = coincore[account.asset] else {
            fatalError("asset for \(account) not found")
        }
        return asset
            .parse(address: address)
            .map { address -> Result<ReceiveAddress, Error> in
                guard let address = address else {
                    return .failure(CryptoAssetError.addressParseFailure)
                }
                return .success(address)
            }
    }
}
