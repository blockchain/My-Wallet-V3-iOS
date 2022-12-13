// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

public class AllCryptoAssetsBalanceService: AllCryptoAssetsServiceAPI {
    private let custodialBalanceRepository: CustodialAssetsRepositoryAPI
    private let nonCustodialBalanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let coincore: CoincoreAPI
    private let priceService: PriceServiceAPI
    private let app: AppProtocol

    public init(
        allCrypoBalanceRepository: CustodialAssetsRepositoryAPI,
        nonCustodialBalanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        coincore: CoincoreAPI,
        app: AppProtocol
    ) {
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.custodialBalanceRepository = allCrypoBalanceRepository
        self.nonCustodialBalanceRepository = nonCustodialBalanceRepository
        self.coincore = coincore
        self.app = app
    }

    public func getAllCryptoAssetsInfo() async -> [AssetBalanceInfo] {
        (try? await custodialBalanceRepository.assetsInfo.await()) ?? []
    }

    public func getFiatAssetsInfo() async -> [AssetBalanceInfo] {
        var assetsInfo: [AssetBalanceInfo] = []

        let asset = coincore.fiatAsset
        if let accountGroup = try? await asset.accountGroup(filter: .all).await(),
           let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await() {
            let sortedAccounts =   accountGroup
                .accounts
                .sorted(by: { $0.currencyType.fiatCurrency == fiatCurrency && $1.currencyType.fiatCurrency != fiatCurrency })

            for account in sortedAccounts {
                if let balance = try? await account.balance.await() {
                    let actions = try? await account.actions.await()
                    assetsInfo.append(AssetBalanceInfo(
                        cryptoBalance: balance,
                        fiatBalance: nil,
                        currency: account.currencyType,
                        delta: nil,
                        actions: actions
                    ))
                }
            }
        }

        return assetsInfo
    }

    public func getAllNonCustodialAssets() async -> [AssetBalanceInfo] {
        var assetsInfo: [AssetBalanceInfo] = []
        if let balanceInfo = try? await nonCustodialBalanceRepository.balances.await() {
            let groupedDictionary = Dictionary(grouping: balanceInfo.balances, by: { $0.balance.currency.name })
            var groupedTotalBalances: [MoneyValue] = []
            groupedDictionary.forEach { _, balances in
                if let firstBalance = balances.first?.balance,
                   let cryptoCurrency = firstBalance.currencyType.cryptoCurrency
                {
                    let balanceSum = balances.reduce(into: MoneyValue.zero(currency: cryptoCurrency)) { partialResult, element in
                        try? partialResult += element.balance
                    }
                    groupedTotalBalances.append(balanceSum)
                }
            }

            for balance in groupedTotalBalances {
                async let fiatCurrency = try? await fiatCurrencyService.currency.await()
                let currencyType = balance.currencyType
                if let cryptoCurrency = currencyType.cryptoCurrency,
                   let fiatCurrency = await fiatCurrency,
                   let fiatBalance = try? await priceService
                    .price(of: cryptoCurrency, in: fiatCurrency, at: .now)
                    .await()
                {
                    assetsInfo.append(AssetBalanceInfo(
                        cryptoBalance: balance,
                        fiatBalance: MoneyValuePair(base: balance, exchangeRate: fiatBalance.moneyValue),
                        currency: currencyType,
                        delta: nil
                    ))
                }
            }
        }

        return assetsInfo
    }
}
