// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureStakingDomain
import Localization
import MoneyKit
import RxSwift
import ToolKit

public final class CryptoActiveRewardsAccount: CryptoAccount, ActiveRewardsAccount {

    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
        earn.activity(currency: asset)
            .map { activity in
                activity.map { ActivityItemEvent.earn(.active, $0) }
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.available)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var pendingBalance: AnyPublisher<MoneyDomainKit.MoneyValue, Error> {
        balances
            .map(\.balance?.pending)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var actionableBalance: AnyPublisher<MoneyDomainKit.MoneyValue, Error> {
        balances
            .map(\.balance)
            .map(\.?.withdrawable)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var pendingWithdrawals: AnyPublisher<[EarnWithdrawalPendingRequest], Error> {
        earn.pendingWithdrawalRequests(currency: asset).mapError { $0 as Error }.eraseToAnyPublisher()
    }

    public private(set) lazy var identifier: AnyHashable = "CryptoActiveRewardsAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let assetName: String
    public let isDefault: Bool = false
    public var accountType: AccountType = .trading

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        earn.address(currency: asset)
            .tryMap { [asset, cryptoReceiveAddressFactory, onTxCompleted] address throws -> ReceiveAddress in
                try cryptoReceiveAddressFactory.makeExternalAssetAddress(
                    address: address.accountRef,
                    label: "\(asset.code) \(LocalizationConstants.activeRewardsAccount)",
                    onTxCompleted: onTxCompleted
                )
                .get() as ReceiveAddress
            }
            .eraseToAnyPublisher()
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        balances
            .map { $0 != .absent }
            .eraseError()
    }

    private let priceService: PriceServiceAPI
    private let earn: EarnAccountService
    private let cryptoReceiveAddressFactory: ExternalAssetAddressFactory

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        earn.balances()
            .map(CustodialAccountBalanceStates.init(accounts:))
            .map(\.[asset.currencyType])
            .replaceError(with: CustodialAccountBalanceState.absent)
            .eraseToAnyPublisher()
    }

    public init(
        asset: CryptoCurrency,
        earn: EarnAccountService = resolve(tag: EarnProduct.active),
        priceService: PriceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    ) {
        self.label = asset.defaultActiveRewardsWalletName
        self.assetName = asset.assetModel.name
        self.asset = asset
        self.earn = earn
        self.priceService = priceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .activeRewardsWithdraw:
            return actionableBalance.map(\.isPositive).eraseToAnyPublisher()
        case .viewActivity:
            return .just(true)
        case _:
            return .just(false)
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func invalidateAccountBalance() {
        earn.invalidateBalances()
    }
}
