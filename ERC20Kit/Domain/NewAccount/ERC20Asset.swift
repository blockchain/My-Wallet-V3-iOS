//
//  ERC20Asset.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20Asset<Token: ERC20Token>: CryptoAsset {

    let asset: CryptoCurrency = Token.assetType

    var defaultAccount: Single<SingleAccount> {
        walletAccountBridge.wallets
            .map { $0.first }
            .map { wallet -> EthereumWalletAccount in
                guard let wallet = wallet else {
                    throw CryptoAssetError.noDefaultAccount
                }
                return wallet
            }
            .map { wallet -> SingleAccount in
                ERC20CryptoAccount<Token>(id: wallet.publicKey)
            }
    }
    
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let walletAccountBridge: EthereumWalletAccountBridgeAPI
    private let errorRecorder: ErrorRecording
    private let internalFeatureFlag: InternalFeatureFlagServiceAPI
    
    init(walletAccountBridge: EthereumWalletAccountBridgeAPI = resolve(),
         errorRecorder: ErrorRecording = resolve(),
         exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
         internalFeatureFlag: InternalFeatureFlagServiceAPI = resolve()) {
        self.walletAccountBridge = walletAccountBridge
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.internalFeatureFlag = internalFeatureFlag
    }

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        }
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        guard !address.isEmpty else {
            return .just(nil)
        }
        let validated = EthereumAddress(stringLiteral: address)
        guard validated.isValid else {
            return .just(nil)
        }
        return .just(
            ERC20ReceiveAddress<Token>(
                asset: Token.assetType,
                address: address,
                // TODO: Correct label
                label: address,
                onTxCompleted: { _ in Completable.empty() }
            )
        )
    }

    // MARK: - Helpers

    private var allAccountsGroup: Single<AccountGroup> {
        Single.zip(nonCustodialGroup,
                   custodialGroup,
                   interestGroup,
                   exchangeGroup)
            .map { (nonCustodialGroup, custodialGroup, interestGroup, exchangeGroup) -> [SingleAccount] in
                    nonCustodialGroup.accounts +
                    custodialGroup.accounts +
                    interestGroup.accounts +
                    exchangeGroup.accounts
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: Token.assetType, accounts: accounts)
            }
    }

    private var custodialGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: Token.assetType, accounts: [CryptoTradingAccount(asset: Token.assetType)]))
    }

    private var interestGroup: Single<AccountGroup> {
        Single
            .just(CryptoInterestAccount(asset: Token.assetType))
            .map { CryptoAccountCustodialGroup(asset: Token.assetType, accounts: [$0]) }
    }
    
    private var exchangeGroup: Single<AccountGroup> {
        let asset = self.asset
        guard internalFeatureFlag.isEnabled(.nonCustodialSendP2) else {
            return .just(CryptoAccountCustodialGroup(asset: asset, accounts: []))
        }
        return exchangeAccountProvider
            .account(for: asset)
            .catchError { error in
                /// TODO: This shouldn't prevent users from seeing all accounts.
                /// Potentially return nil should this fail.
                guard let serviceError = error as? ExchangeAccountsNetworkError else {
                    throw error
                }
                switch serviceError {
                case .missingAccount:
                    return Single.just(nil)
                }
            }
            .map { account in
                guard let account = account else {
                    return CryptoAccountCustodialGroup(asset: asset, accounts: [])
                }
                return CryptoAccountCustodialGroup(asset: asset, accounts: [account])
            }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        walletAccountBridge.wallets
            .map { wallets -> [SingleAccount] in
                wallets.map { ERC20CryptoAccount<Token>(id: $0.publicKey) }
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: Token.assetType, accounts: accounts)
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
