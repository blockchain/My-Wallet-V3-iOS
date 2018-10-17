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
       return configuration.sdk.accounts
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
                var account = StellarAccount(identifier: details.accountId)
                
                details.balances.forEach({ balance in
                    if let issuer = balance.assetIssuer {
                        let assetAddress = AssetAddressFactory.create(
                            fromAddressString: issuer,
                            assetType: .stellar
                        )
                        let value = Decimal(string: balance.balance) ?? 0.0
                        let assetAccount = AssetAccount(
                            index: 0,
                            address: assetAddress,
                            balance: value,
                            name: ""
                        )
                        account.assetAccounts.append(assetAccount)
                    }
                })
                
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
