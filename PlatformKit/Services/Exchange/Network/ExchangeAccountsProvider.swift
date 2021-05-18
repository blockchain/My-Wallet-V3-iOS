//
//  ExchangeAccountsProvider.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/4/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountsProviderAPI {
    var accounts: Single<[CryptoExchangeAccount]> { get }
    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount?>
}

final class ExchangeAccountsProvider: ExchangeAccountsProviderAPI {
    
    // MARK: - Public (ExchangeAccountsProviderAPI)
    
    var accounts: Single<[CryptoExchangeAccount]> {
        statusService.hasLinkedExchangeAccount
            .map { hasLinkedExchangeAccount -> Void in
                guard hasLinkedExchangeAccount else {
                    throw ExchangeAccountsNetworkError.missingAccount
                }
                return ()
            }
            .flatMap { Single.just(CryptoCurrency.allCases) }
            .flatMap(weak: self) { (self, currencies) -> Single<[CryptoExchangeAccount]> in
                let elements = currencies.map { currency in
                    self.client
                        .exchangeAddress(with: currency)
                        .map { response in
                            CryptoExchangeAccount(response: response)
                        }
                }
                
                return Single.zip(elements)
            }
    }
    
    // MARK: - Private Properties
    
    private let statusService: ExchangeAccountStatusServiceAPI
    private let client: ExchangeAccountsProviderClientAPI
    
    // MARK: - Init
    
    init(client: ExchangeAccountsClientAPI = resolve(),
         statusService: ExchangeAccountStatusServiceAPI = resolve()) {
        self.statusService = statusService
        self.client = client
    }
    
    // MARK: - ExchangeAccountsProviderAPI
    
    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount?> {
        statusService.hasLinkedExchangeAccount
            .map { hasLinkedExchangeAccount -> Void in
                guard hasLinkedExchangeAccount else {
                    throw ExchangeAccountsNetworkError.missingAccount
                }
                return ()
            }
            .flatMap(weak: self) { (self, _) in
                self.client
                    .exchangeAddress(with: currency)
                    .map { CryptoExchangeAccount(response: $0) }
            }
    }
}
