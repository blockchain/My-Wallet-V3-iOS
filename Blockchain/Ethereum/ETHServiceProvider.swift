//
//  ETHServiceProvider.swift
//  Blockchain
//
//  Created by Jack on 26/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import EthereumKit

protocol ETHDependencies {
    var repository: EthereumWalletAccountRepository { get }
    var assetAccountRepository: EthereumAssetAccountRepository { get }
    var transactionService: EthereumHistoricalTransactionService { get }
}

struct ETHServices: ETHDependencies {
    let repository: EthereumWalletAccountRepository
    let assetAccountRepository: EthereumAssetAccountRepository
    let transactionService: EthereumHistoricalTransactionService

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.repository = EthereumWalletAccountRepository(with: wallet.ethereum)
        self.assetAccountRepository = EthereumAssetAccountRepository(
            service: EthereumAssetAccountDetailsService(
                with: wallet.ethereum
            )
        )
        self.transactionService = EthereumHistoricalTransactionService(
            with: wallet.ethereum
        )
    }
}

final class ETHServiceProvider {
    
    let services: ETHServices
    
    fileprivate let disposables = CompositeDisposable()
    
    static let shared = ETHServiceProvider.make()
    
    class func make() -> ETHServiceProvider {
        return ETHServiceProvider(services: ETHServices())
    }
    
    init(services: ETHServices) {
        self.services = services
    }
    
    var repository: EthereumWalletAccountRepository {
        return services.repository
    }
    
    var assetAccountRepository: EthereumAssetAccountRepository {
        return services.assetAccountRepository
    }
    
    var transactionService: EthereumHistoricalTransactionService {
        return services.transactionService
    }
}
