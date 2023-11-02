// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import Errors
import Localization
import MoneyKit
import PlatformKit
import ToolKit
import WalletPayloadKit

final class BitcoinCryptoAccount: BitcoinChainCryptoAccount {

    let coinType: BitcoinChainCoin = .bitcoin

    private(set) lazy var identifier: String = "BitcoinCryptoAccount.\(asset.code).\(xPub.address).\(xPub.derivationType)"
    let label: String
    let assetName: String
    let asset: CryptoCurrency = .bitcoin
    let isDefault: Bool
    let hdAccountIndex: Int
    let isImported: Bool
    let importedPrivateKey: String?

    func createTransactionEngine() -> Any {
        BitcoinOnChainTransactionEngineFactory<BitcoinToken>()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: .bitcoin))
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        if isImported {
            importedAddressBalance()
        } else {
            balanceRepository
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

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        if !isImported {
            receiveAddressProvider.receiveAddressProvider(UInt32(hdAccountIndex))
                .map { [label, onTxCompleted] receiveAddress -> ReceiveAddress in
                    BitcoinChainReceiveAddress<BitcoinToken>(
                        address: receiveAddress,
                        label: label,
                        onTxCompleted: onTxCompleted
                    )
                }
                .eraseToAnyPublisher()
        } else {
            .just(
                BitcoinChainReceiveAddress<BitcoinToken>(
                    address: xPub.address,
                    label: label,
                    onTxCompleted: onTxCompleted
                )
            )
        }
    }

    var firstReceiveAddress: AnyPublisher<ReceiveAddress, Error> {
        if !isImported {
            receiveAddressProvider.firstReceiveAddressProvider(UInt32(hdAccountIndex))
                .map { [label, onTxCompleted] receiveAddress -> ReceiveAddress in
                    BitcoinChainReceiveAddress<BitcoinToken>(
                        address: receiveAddress,
                        label: label,
                        onTxCompleted: onTxCompleted
                    )
                }
                .eraseToAnyPublisher()
        } else {
            receiveAddress
        }
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return canPerformInterestTransfer
            .eraseToAnyPublisher()
    }

    let xPub: XPub // TODO: Change this to `XPubs`

    private let app: AppProtocol
    private let priceService: PriceServiceAPI
    private let walletAccount: BitcoinWalletAccount
    private let receiveAddressProvider: BitcoinChainReceiveAddressProviderAPI
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let multiAddrFetcher: FetchMultiAddressFor

    init(
        walletAccount: BitcoinWalletAccount,
        isDefault: Bool,
        app: AppProtocol = resolve(),
        priceService: PriceServiceAPI = resolve(),
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI = resolve(),
        multiAddrFetcher: @escaping FetchMultiAddressFor = resolve(tag: BitcoinChainCoin.bitcoin),
        receiveAddressProvider: BitcoinChainReceiveAddressProviderAPI = resolve(
            tag: BitcoinChainKit.BitcoinChainCoin.bitcoin
        )
    ) {
        self.xPub = walletAccount.defaultXPub
        self.hdAccountIndex = walletAccount.index
        self.label = walletAccount.label
        self.assetName = CryptoCurrency.bitcoin.assetModel.name
        self.isDefault = isDefault
        self.isImported = walletAccount.imported
        self.importedPrivateKey = walletAccount.importedPrivateKey
        self.priceService = priceService
        self.walletAccount = walletAccount
        self.receiveAddressProvider = receiveAddressProvider
        self.app = app
        self.balanceRepository = balanceRepository
        self.multiAddrFetcher = multiAddrFetcher
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        if isImported {
            .just(false)
        } else {
            accountCan(perform: action)
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
        // TODO: @native-wallet allow BTC accounts to be renamed.
        .just(())
    }

    func invalidateAccountBalance() {}
}
