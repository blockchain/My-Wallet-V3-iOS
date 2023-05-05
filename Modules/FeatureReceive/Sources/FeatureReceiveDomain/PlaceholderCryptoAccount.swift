// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

/// A CryptoAccount, NonCustodialAccount object used by Receive screen to display currencies that are not yet currently loaded.
public final class PlaceholderCryptoAccount: CryptoAccount, NonCustodialAccount {

    public var asset: CryptoCurrency

    public var isDefault: Bool = true

    public var identifier: AnyHashable {
        asset.code
    }

    public let accountType: AccountType = .nonCustodial

    public var balance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
        .just([])
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        .just(.zero(baseCurrency: asset.currencyType, quoteCurrency: fiatCurrency.currencyType))
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        .just(.zero(baseCurrency: asset.currencyType, quoteCurrency: fiatCurrency.currencyType))
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        .just(true)
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }

    public var label: String {
        asset.defaultWalletName
    }

    public var assetName: String {
        asset.name
    }

    public init(
        asset: CryptoCurrency
    ) {
        self.asset = asset
    }

    public func invalidateAccountBalance() {
        // NO-OP
    }
}
