//
//  CryptoExchangeAccount.swift
//  PlatformKit
//
//  Created by Paulo on 14/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

/// State of Exchange account linking
public enum ExchangeAccountState: String {
    case pending = "PENDING"
    case active = "ACTIVE"
    case blocked = "BLOCKED"
    
    /// Returns `true` for an active state
    public var isActive: Bool {
        switch self {
        case .active:
            return true
        case .pending, .blocked:
            return false
        }
    }
    
    // MARK: - Init
    
    init(state: CryptoExchangeAddressResponse.State) {
        switch state {
        case .active:
            self = .active
        case .blocked:
            self = .blocked
        case .pending:
            self = .pending
        }
    }
}

public protocol ExchangeAccount: CryptoAccount {
    var state: ExchangeAccountState { get }
}

public class CryptoExchangeAccount: ExchangeAccount {
    
    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }
    
    public var balance: Single<MoneyValue> {
        /// Exchange API does not return a balance.
        .just(MoneyValue.zero(currency: asset))
    }
    
    public var receiveAddress: Single<ReceiveAddress> {
        .just(
            CryptoExchangeAccountReceiveAddress(
                asset: asset,
                address: address,
                label: label,
                onTxCompleted: onTxCompleted
            )
        )
    }
    
    public var pendingBalance: Single<MoneyValue> {
        /// Exchange API does not return a balance.
        .just(MoneyValue.zero(currency: asset))
    }
    
    public var actions: Single<AvailableActions> {
        .just([.receive])
    }
    
    public var isFunded: Single<Bool> {
        .just(true)
    }
    
    public lazy var id: String = "CryptoExchangeAccount." + asset.code
    public let accountType: SingleAccountType = .nonCustodial
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public let label: String
    public let state: ExchangeAccountState
    
    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        /// Exchange API does not return a balance.
        .just(.zero(currency: fiatCurrency))
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }
    
    // MARK: - Private Properties
    
    private let address: String
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    
    // MARK: - Init
    
    init(response: CryptoExchangeAddressResponse,
         exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve()) {
        self.label = response.assetType.defaultExchangeWalletName
        self.asset = response.assetType
        self.address = response.address
        self.state = .init(state: response.state)
        self.exchangeAccountProvider = exchangeAccountProvider
    }
}
