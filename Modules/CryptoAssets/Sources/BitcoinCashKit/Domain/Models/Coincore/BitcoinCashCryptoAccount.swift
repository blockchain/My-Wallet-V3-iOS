// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import Localization
import MoneyKit
import PlatformKit
import ToolKit
import WalletPayloadKit

final class BitcoinCashCryptoAccount: BitcoinChainCryptoAccount {

    let coinType: BitcoinChainCoin = .bitcoinCash

    private(set) lazy var identifier: String = "BitcoinCashCryptoAccount.\(asset.code).\(xPub.address).\(xPub.derivationType)"
    let label: String
    let assetName: String
    let asset: CryptoCurrency = .bitcoinCash
    let isDefault: Bool
    let hdAccountIndex: Int
    let isImported: Bool
    let importedPrivateKey: String?

    func createTransactionEngine() -> Any {
        BitcoinOnChainTransactionEngineFactory<BitcoinCashToken>()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: .bitcoinCash))
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        if isImported {
            return importedAddressBalance()
        } else {
            return balanceRepository
                .balances
                .map { [asset, hdAccountIndex] balances in
                    balances.balance(
                        index: hdAccountIndex,
                        currency: asset
                    ) ?? MoneyValue.zero(currency: asset)
                }
                .eraseToAnyPublisher()
        }
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        if isImported {
            return .just(
                BitcoinChainReceiveAddress<BitcoinCashToken>(
                    address: xPub.address,
                    label: label,
                    onTxCompleted: onTxCompleted
                )
            )
        } else {
            return receiveAddressProvider
                .receiveAddressProvider(UInt32(hdAccountIndex))
                .map { $0.replacingOccurrences(of: "bitcoincash:", with: "") }
                .eraseError()
                .map { [label, onTxCompleted] address -> ReceiveAddress in
                    BitcoinChainReceiveAddress<BitcoinCashToken>(
                        address: address,
                        label: label,
                        onTxCompleted: onTxCompleted
                    )
                }
                .eraseToAnyPublisher()
        }
    }

    var firstReceiveAddress: AnyPublisher<ReceiveAddress, Error> {
        if isImported {
            return receiveAddress
        } else {
            return receiveAddressProvider
                .firstReceiveAddressProvider(UInt32(hdAccountIndex))
                .map { $0.replacingOccurrences(of: "bitcoincash:", with: "") }
                .eraseError()
                .map { [label, onTxCompleted] address -> ReceiveAddress in
                    BitcoinChainReceiveAddress<BitcoinCashToken>(
                        address: address,
                        label: label,
                        onTxCompleted: onTxCompleted
                    )
                }
                .eraseToAnyPublisher()
        }
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return canPerformInterestTransfer
            .eraseToAnyPublisher()
    }

    let xPub: XPub
    private let priceService: PriceServiceAPI
    private let receiveAddressProvider: BitcoinChainReceiveAddressProviderAPI
    private let app: AppProtocol
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let repository: BitcoinCashWalletAccountRepository
    private let multiAddrFetcher: FetchMultiAddressFor

    init(
        xPub: XPub,
        label: String?,
        isDefault: Bool,
        hdAccountIndex: Int,
        imported: Bool,
        importedPrivateKey: String?,
        app: AppProtocol = resolve(),
        priceService: PriceServiceAPI = resolve(),
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI = resolve(),
        multiAddrFetcher: @escaping FetchMultiAddressFor = resolve(tag: BitcoinChainCoin.bitcoinCash),
        repository: BitcoinCashWalletAccountRepository = resolve(),
        receiveAddressProvider: BitcoinChainReceiveAddressProviderAPI = resolve(
            tag: BitcoinChainKit.BitcoinChainCoin.bitcoinCash
        )
    ) {
        self.xPub = xPub
        self.label = label ?? CryptoCurrency.bitcoinCash.defaultWalletName
        self.assetName = CryptoCurrency.bitcoinCash.name
        self.isDefault = isDefault
        self.isImported = imported
        self.importedPrivateKey = importedPrivateKey
        self.hdAccountIndex = hdAccountIndex
        self.priceService = priceService
        self.receiveAddressProvider = receiveAddressProvider
        self.app = app
        self.balanceRepository = balanceRepository
        self.repository = repository
        self.multiAddrFetcher = multiAddrFetcher
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        if isImported {
            return .just(false)
        } else {
            return accountCan(perform: action)
        }
    }

    private func accountCan(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .receive,
             .send,
             .buy,
             .viewActivity:
            return .just(true)
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw,
             .stakingWithdraw,
             .activeRewardsWithdraw:
            return .just(false)
        case .stakingDeposit:
            guard asset.supports(product: .staking) else { return .just(false) }
            return isFunded
        case .activeRewardsDeposit:
            guard asset.supports(product: .activeRewardsBalance) else { return .just(false) }
            return isFunded
        case .interestTransfer:
            return isInterestTransferAvailable
                .flatMap { [isFunded] isEnabled in
                    isEnabled ? isFunded : .just(false)
                }
                .eraseToAnyPublisher()
        case .sell:
            return hasPositiveDisplayableBalance
        case .swap:
            return .just(true)
        }
    }

    func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    private func importedAddressBalance() -> AnyPublisher<MoneyValue, Error> {
        multiAddrFetcher([xPub])
            .eraseError()
            .map { [asset] response in
                response.addresses
                    .map { address in
                        MoneyValue(cryptoValue:
                            CryptoValue.create(
                                minor: address.finalBalance,
                                currency: asset
                            )
                        )
                    }
            }
            .map { [asset] values in
                values.first ?? .zero(currency: asset)
            }
            .eraseToAnyPublisher()
    }

    func updateLabel(_ newLabel: String) -> AnyPublisher<Void, Never> {
        guard !isImported else {
            return .just(())
        }
        return repository.update(accountIndex: hdAccountIndex, label: newLabel)
    }

    func invalidateAccountBalance() {}
}
