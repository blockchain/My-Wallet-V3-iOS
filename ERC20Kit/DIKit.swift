//
//  DIKit.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import ToolKit
import TransactionKit

extension DependencyContainer {

    // MARK: - ERC20Kit Module

    public static var erc20Kit = module {
        
        single(tag: Tags.ERC20AccountService.addressCache) {
            Atomic<[String: Bool]>([:])
        }

        // MARK: - Aave

        factory(tag: CryptoCurrency.aave) { ERC20Asset<AaveToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<AaveToken>() }

        factory(tag: CryptoCurrency.aave) { ERC20OnChainTransactionEngineFactory<AaveToken>() as OnChainTransactionEngineFactory }

        factory(tag: CryptoCurrency.aave) { ERC20ExternalAssetAddressFactory<AaveToken>() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.aave) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<AaveToken>()
            )
        }

        factory { ERC20BalanceService<AaveToken>() }

        factory {
            AnyERC20AccountAPIClient<AaveToken>(
                accountAPIClient: ERC20AccountAPIClient<AaveToken>()
            )
        }

        factory { ERC20AccountAPIClient<AaveToken>() }

        factory { ERC20AccountService<AaveToken>() }

        factory(tag: CryptoCurrency.aave) { ERC20AssetBalanceFetcher<AaveToken>() as CryptoAccountBalanceFetching }

        factory { AnyERC20HistoricalTransactionService<AaveToken>() }

        factory { ERC20Service<AaveToken>() }

        factory { () -> AnyERC20Service<AaveToken> in
            let service: ERC20Service<AaveToken> = DIKit.resolve()
            return AnyERC20Service<AaveToken>(service)
        }

        factory { CryptoFeeService<ERC20TransactionFee<AaveToken>>() }

        factory {
            AnyCryptoFeeService<ERC20TransactionFee<AaveToken>>
                .erc20(token: AaveToken.self)
        }

        // MARK: - PAX

        factory(tag: CryptoCurrency.pax) { ERC20Asset<PaxToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<PaxToken>() }
        
        factory(tag: CryptoCurrency.pax) { ERC20OnChainTransactionEngineFactory<PaxToken>() as OnChainTransactionEngineFactory }
        
        factory(tag: CryptoCurrency.pax) { ERC20ExternalAssetAddressFactory<PaxToken>() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.pax) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<PaxToken>()
            )
        }

        factory { ERC20BalanceService<PaxToken>() }

        factory {
            AnyERC20AccountAPIClient<PaxToken>(
                accountAPIClient: ERC20AccountAPIClient<PaxToken>()
            )
        }

        factory { ERC20AccountAPIClient<PaxToken>() }
        
        factory { ERC20AccountService<PaxToken>() }

        factory(tag: CryptoCurrency.pax) { ERC20AssetBalanceFetcher<PaxToken>() as CryptoAccountBalanceFetching }
        
        factory { AnyERC20HistoricalTransactionService<PaxToken>() }
        
        factory { ERC20Service<PaxToken>() }

        factory { () -> AnyERC20Service<PaxToken> in
            let service: ERC20Service<PaxToken> = DIKit.resolve()
            return AnyERC20Service<PaxToken>(service)
        }

        factory { CryptoFeeService<ERC20TransactionFee<PaxToken>>() }

        factory {
            AnyCryptoFeeService<ERC20TransactionFee<PaxToken>>
                .erc20(token: PaxToken.self)
        }

        // MARK: - Tether

        factory(tag: CryptoCurrency.tether) { ERC20Asset<TetherToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<TetherToken>() }
        
        factory(tag: CryptoCurrency.tether) { ERC20OnChainTransactionEngineFactory<TetherToken>() as OnChainTransactionEngineFactory }
        
        factory(tag: CryptoCurrency.tether) { ERC20ExternalAssetAddressFactory<TetherToken>() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.tether) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<TetherToken>()
            )
        }

        factory { ERC20BalanceService<TetherToken>() }

        factory {
            AnyERC20AccountAPIClient<TetherToken>(
                accountAPIClient: ERC20AccountAPIClient<TetherToken>()
            )
        }

        factory { ERC20AccountAPIClient<TetherToken>() }
        
        factory { ERC20AccountService<TetherToken>() }

        factory(tag: CryptoCurrency.tether) { ERC20AssetBalanceFetcher<TetherToken>() as CryptoAccountBalanceFetching }

        factory { AnyERC20HistoricalTransactionService<TetherToken>() }

        factory { ERC20Service<TetherToken>() }

        factory { () -> AnyERC20Service<TetherToken> in
            let service: ERC20Service<TetherToken> = DIKit.resolve()
            return AnyERC20Service<TetherToken>(service)
        }

        factory { CryptoFeeService<ERC20TransactionFee<TetherToken>>() }

        factory {
            AnyCryptoFeeService<ERC20TransactionFee<TetherToken>>
                .erc20(token: TetherToken.self)
        }

        // MARK: - WDGLD

        factory(tag: CryptoCurrency.wDGLD) { ERC20Asset<WDGLDToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<WDGLDToken>() }

        factory(tag: CryptoCurrency.wDGLD) { ERC20OnChainTransactionEngineFactory<WDGLDToken>() as OnChainTransactionEngineFactory }

        factory(tag: CryptoCurrency.wDGLD) { ERC20ExternalAssetAddressFactory<WDGLDToken>() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.wDGLD) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<WDGLDToken>()
            )
        }

        factory { ERC20BalanceService<WDGLDToken>() }

        factory {
            AnyERC20AccountAPIClient<WDGLDToken>(
                accountAPIClient: ERC20AccountAPIClient<WDGLDToken>()
            )
        }

        factory { ERC20AccountAPIClient<WDGLDToken>() }

        factory { ERC20AccountService<WDGLDToken>() }

        factory(tag: CryptoCurrency.wDGLD) { ERC20AssetBalanceFetcher<WDGLDToken>() as CryptoAccountBalanceFetching }

        factory { AnyERC20HistoricalTransactionService<WDGLDToken>() }

        factory { ERC20Service<WDGLDToken>() }

        factory { () -> AnyERC20Service<WDGLDToken> in
            let service: ERC20Service<WDGLDToken> = DIKit.resolve()
            return AnyERC20Service<WDGLDToken>(service)
        }

        factory { CryptoFeeService<ERC20TransactionFee<WDGLDToken>>() }

        factory {
            AnyCryptoFeeService<ERC20TransactionFee<WDGLDToken>>
                .erc20(token: WDGLDToken.self)
        }

        // MARK: - Yearn Finance

        factory(tag: CryptoCurrency.yearnFinance) { ERC20Asset<YearnFinanceToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<YearnFinanceToken>() }

        factory(tag: CryptoCurrency.yearnFinance) { ERC20OnChainTransactionEngineFactory<YearnFinanceToken>() as OnChainTransactionEngineFactory }

        factory(tag: CryptoCurrency.yearnFinance) { ERC20ExternalAssetAddressFactory<YearnFinanceToken>() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.yearnFinance) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<YearnFinanceToken>()
            )
        }

        factory { ERC20BalanceService<YearnFinanceToken>() }

        factory {
            AnyERC20AccountAPIClient<YearnFinanceToken>(
                accountAPIClient: ERC20AccountAPIClient<YearnFinanceToken>()
            )
        }

        factory { ERC20AccountAPIClient<YearnFinanceToken>() }

        factory { ERC20AccountService<YearnFinanceToken>() }

        factory(tag: CryptoCurrency.yearnFinance) { ERC20AssetBalanceFetcher<YearnFinanceToken>() as CryptoAccountBalanceFetching }

        factory { AnyERC20HistoricalTransactionService<YearnFinanceToken>() }

        factory { ERC20Service<YearnFinanceToken>() }

        factory { () -> AnyERC20Service<YearnFinanceToken> in
            let service: ERC20Service<YearnFinanceToken> = DIKit.resolve()
            return AnyERC20Service<YearnFinanceToken>(service)
        }

        factory { CryptoFeeService<ERC20TransactionFee<YearnFinanceToken>>() }

        factory {
            AnyCryptoFeeService<ERC20TransactionFee<YearnFinanceToken>>
                .erc20(token: YearnFinanceToken.self)
        }
    }
}

extension AnyCryptoFeeService {
    fileprivate static func erc20<Token: ERC20Token>(
        token: Token.Type,
        service: CryptoFeeService<ERC20TransactionFee<Token>> = resolve()
    ) -> AnyCryptoFeeService<ERC20TransactionFee<Token>> {
        AnyCryptoFeeService<ERC20TransactionFee<Token>>(service: service)
    }
}

extension DependencyContainer {
    struct Tags {
        struct ERC20AccountService {
            static let addressCache = String(describing: Self.self)
        }
    }
}
