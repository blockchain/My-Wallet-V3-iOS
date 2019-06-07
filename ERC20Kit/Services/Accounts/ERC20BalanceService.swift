//
//  ERC20BalanceService.swift
//  ERC20Kit
//
//  Created by Jack on 18/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import EthereumKit

public protocol ERC20BalanceServiceAPI {
    associatedtype Token: ERC20Token
    
    func balance(for address: EthereumAddress) -> Single<ERC20TokenValue<Token>>
}

public class AnyERC20BalanceService<Token: ERC20Token>: ERC20BalanceServiceAPI {
    
    public var ethereumAddress: Single<String> {
        return bridge.address
    }
    
    public var balanceForDefaultAccount: Single<ERC20TokenValue<Token>> {
        return ethereumAddress
            .flatMap { [weak self] address -> Single<ERC20TokenValue<Token>> in
                guard let self = self else { throw ERC20Error.unknown }
                guard let ethereumAddress = EthereumAddress(rawValue: address) else {
                    throw ERC20Error.unknown
                }
                return self.balance(for: ethereumAddress)
            }
    }
    
    private let bridge: EthereumWalletBridgeAPI
    private let accountClient: AnyERC20AccountAPIClient<Token>
    
    init<C: ERC20AccountAPIClientAPI>(with bridge: EthereumWalletBridgeAPI, accountClient: C) where C.Token == Token {
        self.bridge = bridge
        self.accountClient = AnyERC20AccountAPIClient(accountAPIClient: accountClient)
    }
    
    public func balance(for address: EthereumAddress) -> Single<ERC20TokenValue<Token>> {
        return accountClient.fetchWalletAccount(ethereumAddress: address.rawValue)
            .map { Token.cryptoValueFrom(minorValue: $0.balance) ?? Token.cryptoValueFrom(majorValue: Decimal(0))! }
    }
}
