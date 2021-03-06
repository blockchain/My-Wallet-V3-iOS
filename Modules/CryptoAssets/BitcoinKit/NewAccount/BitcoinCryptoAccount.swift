// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class BitcoinCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: AnyHashable = "BitcoinCryptoAccount.\(xPub.address).\(xPub.derivationType)"
    let label: String
    let asset: CryptoCurrency = .bitcoin
    let isDefault: Bool

    func createTransactionEngine() -> Any {
        BitcoinOnChainTransactionEngineFactory<BitcoinToken>()
    }

    var pendingBalance: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .bitcoin))
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balances(for: walletAccount.publicKeys.xpubs)
            .moneyValue
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
        bridge.receiveAddress(forXPub: xPub.address)
            .flatMap { [bridge] address -> Single<(Int32, String)> in
                Single.zip(bridge.walletIndex(for: address), .just(address))
            }
            .map { [label, onTxCompleted] (index, address) -> ReceiveAddress in
                BitcoinChainReceiveAddress<BitcoinToken>(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted,
                    index: index
                )
            }
    }

    private let xPub: XPub
    private let balanceService: BalanceServiceAPI
    private let bridge: BitcoinWalletBridgeAPI
    private let hdAccountIndex: Int
    private let fiatPriceService: FiatPriceServiceAPI
    private let walletAccount: BitcoinWalletAccount

    init(walletAccount: BitcoinWalletAccount,
         isDefault: Bool,
         balanceService: BalanceServiceAPI = resolve(tag: BitcoinChainKit.BitcoinChainCoin.bitcoin),
         fiatPriceService: FiatPriceServiceAPI = resolve(),
         bridge: BitcoinWalletBridgeAPI = resolve()) {
        self.xPub = walletAccount.publicKeys.default
        self.hdAccountIndex = walletAccount.index
        self.label = walletAccount.label ?? CryptoCurrency.bitcoin.defaultWalletName
        self.isDefault = isDefault
        self.balanceService = balanceService
        self.fiatPriceService = fiatPriceService
        self.bridge = bridge
        self.walletAccount = walletAccount
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
