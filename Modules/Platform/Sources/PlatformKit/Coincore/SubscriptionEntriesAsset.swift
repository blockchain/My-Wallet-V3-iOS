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
        FiatCustodialAccount(fiatCurrency: fiatCurrency)
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
