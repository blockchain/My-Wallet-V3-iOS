//
//  BitcoinAsset.swift.swift
//  BitcoinKit
//
//  Created by Paulo on 11/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class BitcoinAsset: CryptoAsset {

    let asset: CryptoCurrency = .bitcoin

    var defaultAccount: Single<SingleAccount> {
        repository.defaultAccount
            .map { BitcoinCryptoAccount(id: $0.publicKey, label: $0.label, isDefault: true) }
    }

    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let repository: BitcoinWalletAccountRepository
    private let errorRecorder: ErrorRecording
    private let addressValidator: BitcoinAddressValidatorAPI
    private let internalFeatureFlag: InternalFeatureFlagServiceAPI

    init(repository: BitcoinWalletAccountRepository = resolve(),
         errorRecorder: ErrorRecording = resolve(),
         exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
         addressValidator: BitcoinAddressValidatorAPI = resolve(),
         internalFeatureFlag: InternalFeatureFlagServiceAPI = resolve()) {
        self.exchangeAccountProvider = exchangeAccountProvider
        self.repository = repository
        self.errorRecorder = errorRecorder
        self.addressValidator = addressValidator
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
        addressValidator.validate(address: address)
            .andThen(
                .just(
                    BitcoinChainReceiveAddress<BitcoinToken>(
                        address: address,
                        label: address,
                        onTxCompleted: { _ in Completable.empty() }
                    )
                )
            )
            .catchErrorJustReturn(nil)
    }

    // MARK: - Helpers

    private var allAccountsGroup: Single<AccountGroup> {
        let asset = self.asset
        return Single.zip(nonCustodialGroup,
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
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
    }
    
    private var custodialGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: asset, accounts: [CryptoTradingAccount(asset: asset)]))
    }

    private var interestGroup: Single<AccountGroup> {
        let asset = self.asset
        return Single
            .just(CryptoInterestAccount(asset: asset))
            .map { CryptoAccountCustodialGroup(asset: asset, accounts: [$0]) }
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
        let asset = self.asset
        return repository
            .accounts
            .flatMap(weak: self) { (self, accounts) -> Single<(defaultAccount: BitcoinWalletAccount, accounts: [BitcoinWalletAccount])> in
                self.repository.defaultAccount
                    .map { ($0, accounts) }
            }
            .map { (defaultAccount, accounts) -> [SingleAccount] in
                accounts.map {
                    BitcoinCryptoAccount(
                        id: $0.publicKey,
                        label: $0.label,
                        isDefault: $0.publicKey == defaultAccount.publicKey
                    )
                }
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
