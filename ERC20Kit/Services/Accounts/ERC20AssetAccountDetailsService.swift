//
//  ERC20AssetAccountDetailsService.swift
//  ERC20KitTests
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import EthereumKit

public class ERC20AssetAccountDetailsService: AssetAccountDetailsAPI {
    public typealias AccountDetails = ERC20AssetAccountDetails
    
    // TODO:
    // * Create ERC20 bridge
    public typealias Bridge = EthereumWalletBridgeAPI

    private let bridge: Bridge
    private let service: ERC20BalanceServiceAPI

    public convenience init(with bridge: Bridge, paxAccountClient: PaxAccountAPIClientAPI) {
        self.init(
            with: bridge,
            service: PaxService(
                with: bridge,
                paxAccountClient: paxAccountClient
            )
        )
    }
    
    public init(with bridge: Bridge, service: ERC20BalanceServiceAPI) {
        self.bridge = bridge
        self.service = service
    }

    // What is AccountID???
    public func accountDetails(for accountID: AccountID) -> Maybe<AccountDetails> {
        return bridge.address
            .flatMap { address -> Single<(String, CryptoValue)> in
                return self.service.paxBalance(for: address)
                    .flatMap { balance -> Single<(String, CryptoValue)> in
                        return Single.just((address, balance))
                    }
            }
            .flatMap { value -> Single<ERC20AssetAccountDetails> in
                let (address, balance) = value
                return Single.just(
                    ERC20AssetAccountDetails(
                        account: ERC20AssetAccountDetails.Account(
                            walletIndex: 0,
                            accountAddress: address,
                            name: ""
                        ),
                        balance: balance
                    )
                )
            }
            .asMaybe()
    }
}

public protocol ERC20BalanceServiceAPI {
    func paxBalance(for address: String) -> Single<CryptoValue>
}

public class ECR20BalanceService<T: AssetAccountDetails>: ERC20BalanceServiceAPI {
    
    public var ethereumAddress: Single<String> {
        return bridge.address
    }
    
    public var balanceForDetaultAccount: Single<CryptoValue> {
        if let cachedAccount = cachedAccount {
            return Single.just(CryptoValue.paxFromMajor(string: cachedAccount.balance)!) // TODO: don't cache this
        }
        return ethereumAddress
            .flatMap { address -> Single<CryptoValue> in
                return self.balance(for: address)
            }
    }
    
    public func balance(for address: String) -> Single<CryptoValue> {
        return self.paxAccountClient.fetchWalletAccount(ethereumAddress: address)
            .map { account in
                return account.balance
            }
    }
    
    private var cachedAccount: PaxAccount?
    
    private let bridge: EthereumWalletBridgeAPI
    private let paxAccountClient: AnyERC20AccountAPIClient<T>
    
    init<C: ERC20AccountAPIClientAPI>(with bridge: EthereumWalletBridgeAPI, paxAccountClient: C) where C.Account == T {
        self.bridge = bridge
        self.paxAccountClient = AnyERC20AccountAPIClient(accountAPIClient: paxAccountClient)
    }
}

// https://api.staging.blockchain.info/v2/eth/data/account/<ethereum_address>/token/<erc20_contract_address>/wallet

public protocol PaxAccountAPIClientAPI {
    func fetchWalletAccount(ethereumAddress: String) -> Single<PaxAccount>
}

public protocol Act {
    
}

public protocol ERC20AccountAPIClientAPI {
    associatedtype Account: AssetAccountDetails
    
    func fetchWalletAccount(ethereumAddress: String) -> Single<Account>
}

final class AnyERC20AccountAPIClient<T: AssetAccountDetails>: ERC20AccountAPIClientAPI {
    private let fetchAccountClosure: (String) -> Single<T>
    
    init<C: ERC20AccountAPIClientAPI>(accountAPIClient: C) where C.Account == T {
        self.fetchAccountClosure = accountAPIClient.fetchWalletAccount
    }
    
    func fetchWalletAccount(ethereumAddress: String) -> Single<T> {
        return fetchAccountClosure(ethereumAddress)
    }
}

//public final class AnyERC20AccountAPIClient<T>: ERC20AccountAPIClientAPI {
//
//    init<T>(t: T) where T == ERC20AccountAPIClientAPI.Account {
//
//    }
//
//    func fetchWalletAccount(ethereumAddress: String) -> Single<T> {
//        fatalError()
//    }
    
//    public var fees: Single<T> {
//        guard let baseURL = URL(string: apiUrl) else {
//            return .error(TradeExecutionAPIError.generic)
//        }
//
//        guard let endpoint = URL.endpoint(
//            baseURL,
//            pathComponents: ["mempool", "fees", T.cryptoType.pathComponent],
//            queryParameters: nil
//            ) else {
//                return .error(TradeExecutionAPIError.generic)
//        }
//        return NetworkRequest.GET(url: endpoint, type: T.self)
//            .do(onError: { error in
//                // TODO: this should be logged remotely
//                Logger.shared.error(error)
//            })
//            .catchErrorJustReturn(T.default)
//    }
//
//    private let apiUrl: String
//
//    init(apiUrl: String = BlockchainAPI.shared.apiUrl) {
//        self.apiUrl = apiUrl
//    }
//}
