//
//  StellarAccountService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

class StellarAccountService: StellarAccountAPI {
    
    fileprivate let configuration: StellarConfiguration
    fileprivate let wallet: Blockchain.Wallet
    fileprivate lazy var service: stellarsdk.AccountService = {
       configuration.sdk.accounts
    }()

    init(
        configuration: StellarConfiguration = .production,
        wallet: Blockchain.Wallet = WalletManager.shared.wallet
        ) {
        self.configuration = configuration
        self.wallet = wallet
    }
    
    func accountDetails(
        for accountID: StellarAccountAPI.AccountID,
        completion: @escaping AccountDetailsCompletion) {
        service.getAccountDetails(accountId: accountID) { response -> Void in
            switch response {
            case .success(details: let details):
                let totalBalance = details.balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
                let assetAddress = AssetAddressFactory.create(
                    fromAddressString: accountID,
                    assetType: .stellar
                )
                let assetAccount = AssetAccount(
                    index: 0,
                    address: assetAddress,
                    balance: totalBalance,
                    name: LocalizationConstants.Stellar.defaultLabelName
                )
                let account = StellarAccount(identifier: accountID, assetAccount: assetAccount)
                completion(.success(account))
            case .failure(error: let error):
                completion(.error(error))
            }
        }
    }
    
    func fundAccount(
        with accountID: StellarAccountAPI.AccountID,
        amount: Decimal,
        completion: @escaping StellarAccountAPI.CompletionHandler) {
        // TODO: Create and fund account
    }
}
