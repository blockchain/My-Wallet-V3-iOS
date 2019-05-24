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
    var assetAccountRepository: ERC20AssetAccountRepository<PaxToken> { get }
    var historicalTransactionService: AnyERC20HistoricalTransactionService<PaxToken> { get }
    var paxService: ERC20Service<PaxToken> { get }
}

struct PAXServices: PAXDependencies {
    let assetAccountRepository: ERC20AssetAccountRepository<PaxToken>
    let historicalTransactionService: AnyERC20HistoricalTransactionService<PaxToken>
    let paxService: ERC20Service<PaxToken>
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         feeService: EthereumFeeServiceAPI = EthereumFeeService.shared) {
        let paxAccountClient = AnyERC20AccountAPIClient<PaxToken>()
        let service = ERC20AssetAccountDetailsService(
            with: wallet.ethereum,
            accountClient: paxAccountClient
        )
        self.assetAccountRepository = ERC20AssetAccountRepository(service: service)
        self.historicalTransactionService = AnyERC20HistoricalTransactionService<PaxToken>(bridge: wallet.ethereum)
        let ethereumAssetAccountRepository: EthereumAssetAccountRepository = EthereumAssetAccountRepository(
            service: EthereumAssetAccountDetailsService(
                with: wallet.ethereum
            )
        )
        self.paxService = ERC20Service<PaxToken>(
            assetAccountRepository: assetAccountRepository,
            ethereumAssetAccountRepository: ethereumAssetAccountRepository,
            feeService: feeService
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
}
