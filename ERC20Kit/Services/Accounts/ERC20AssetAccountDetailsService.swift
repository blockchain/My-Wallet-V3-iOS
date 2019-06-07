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

public class ERC20AssetAccountDetailsService<Token: ERC20Token>: AssetAccountDetailsAPI {
    public typealias AccountDetails = ERC20AssetAccountDetails
    
    public typealias Bridge = EthereumWalletBridgeAPI

    private let bridge: Bridge
    private let service: AnyERC20BalanceService<Token>
    
    public convenience init<C: ERC20AccountAPIClientAPI>(with bridge: Bridge, accountClient: C) where C.Token == Token {
        self.init(
            with: bridge,
            service: AnyERC20BalanceService<Token>(
                with: bridge,
                accountClient: accountClient
            )
        )
    }
    
    public init(with bridge: Bridge, service: AnyERC20BalanceService<Token>) {
        self.bridge = bridge
        self.service = service
    }
    
    public func accountDetails(for accountID: AccountID) -> Maybe<AccountDetails> {
        return bridge.address
            .flatMap { [weak self] address -> Single<(String, CryptoValue)> in
                guard let self = self else { throw ERC20Error.unknown }
                guard let ethereumAddress = EthereumAddress(rawValue: address) else {
                    throw ERC20Error.unknown
                }
                return self.service.balance(for: ethereumAddress)
                    .flatMap { balance -> Single<(String, CryptoValue)> in
                        return Single.just((address, balance.value))
                    }
            }
            .flatMap { value -> Single<AccountDetails> in
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

