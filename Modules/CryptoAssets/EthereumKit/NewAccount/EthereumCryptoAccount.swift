// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: AnyHashable = "EthereumCryptoAccount.\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        EthereumOnChainTransactionEngineFactory()
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        accountDetailsService.accountDetails()
            .map(\.balance)
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    var actions: Single<AvailableActions> {
        isFunded
            .map { isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(EthereumReceiveAddress(address: publicKey, label: label, onTxCompleted: onTxCompleted))
    }

    private let publicKey: String
    private let hdAccountIndex: Int
    private let accountDetailsService: EthereumAccountDetailsServiceAPI
    private let fiatPriceService: FiatPriceServiceAPI
    private let bridge: EthereumWalletBridgeAPI

    init(
        publicKey: String,
        label: String? = nil,
        hdAccountIndex: Int,
        bridge: EthereumWalletBridgeAPI = resolve(),
        accountDetailsService: EthereumAccountDetailsServiceAPI = resolve(),
        fiatPriceService: FiatPriceServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve()
    ) {
        let asset = CryptoCurrency.ethereum
        self.asset = asset
        self.publicKey = publicKey
        self.hdAccountIndex = hdAccountIndex
        self.fiatPriceService = fiatPriceService
        self.accountDetailsService = accountDetailsService
        self.bridge = bridge
        self.label = label ?? asset.defaultWalletName
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .send,
             .viewActivity:
            return .just(true)
        case .deposit,
             .buy,
             .sell,
             .withdraw:
            return .just(false)
        case .swap:
            return isFunded
        }
    }

    func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency),
                balance
            )
            .map { (fiatPrice, balance) in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }

    func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency, date: date),
                balance
            )
            .map { (fiatPrice, balance) in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }
}
