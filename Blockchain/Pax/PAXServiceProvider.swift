//
//  PaxServiceProvider.swift
//  Blockchain
//
//  Created by Jack on 12/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import EthereumKit

protocol PAXDependencies {
    var accounts: PaxAccountAPI { get }
}

struct PAXServices: PAXDependencies {
    
    let accounts: PaxAccountAPI
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.accounts = PaxAccountService(with: wallet.ethereum)
    }
}

final class PAXServiceProvider {
    
    let services: PAXServices
    
    fileprivate let disposables = CompositeDisposable()
    
    static let shared = PAXServiceProvider.make()
    
    class func make() -> PAXServiceProvider {
        return PAXServiceProvider(services: PAXServices())
    }
    
    init(services: PAXServices) {
        self.services = services
    }
    
//    var repository: EthereumWalletAccountRepository {
//        return services.repository
//    }
//
//    var assetAccountRepository: EthereumAssetAccountRepository {
//        return services.assetAccountRepository
//    }
//
//    var transactionService: EthereumHistoricalTransactionService {
//        return services.transactionService
//    }
}
