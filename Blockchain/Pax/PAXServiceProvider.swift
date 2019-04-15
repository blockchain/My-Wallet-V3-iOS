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
import ERC20Kit

protocol PAXDependencies {
    var assetAccountRepository: ERC20AssetAccountRepository { get }
}

struct PAXServices: PAXDependencies {
    
    let assetAccountRepository: ERC20AssetAccountRepository
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        let paxAccountClient = PaxAccountAPIClient()
        
        let service = ERC20AssetAccountDetailsService(
            with: wallet.ethereum,
            paxAccountClient: paxAccountClient
        )
        self.assetAccountRepository = ERC20AssetAccountRepository(
            service: service
        )
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
