// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DelegatedSelfCustodyDomain
import MoneyKit

public protocol SubscriptionEntriesAsset {
    var subscriptionEntries: AnyPublisher<[SubscriptionEntry], Never> { get }
}

struct FiatCustodialAccountFactory: FiatCustodialAccountFactoryAPI {

    @Dependency(\.app) var app

    func fiatCustodialAccount(fiatCurrency: FiatCurrency) -> FiatAccount {
        LazyFiatAccount(
            account: app.publisher(for: blockchain.app.is.external.brokerage)
            .replaceError(with: false)
            .map { useExternalTradingAccount -> FiatAccountWithCapabilities in
                if useExternalTradingAccount {
                    return ExternalBrokerageFiatAccount(currency: fiatCurrency)
                } else {
                    return FiatCustodialAccount(fiatCurrency: fiatCurrency)
                }
            }
            .eraseToAnyPublisher(),
            currency: fiatCurrency
        )
    }
}

struct CustodialCryptoAssetFactory: CustodialCryptoAssetFactoryAPI {
    func custodialCryptoAsset(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        CustodialCryptoAsset(asset: cryptoCurrency)
    }
}

struct CryptoTradingAccountFactory: CryptoTradingAccountFactoryAPI {
    func cryptoTradingAccount(
        cryptoCurrency: CryptoCurrency,
        addressFactory: ExternalAssetAddressFactory
    ) -> CryptoAccount {
        CryptoTradingAccount(asset: cryptoCurrency, cryptoReceiveAddressFactory: addressFactory)
    }
}
