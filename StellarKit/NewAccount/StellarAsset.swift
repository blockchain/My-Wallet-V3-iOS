//
//  StellarAsset.swift
//  StellarKit
//
//  Created by Paulo on 10/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarAsset: CryptoAsset {

    let asset: CryptoCurrency = .stellar

    var defaultAccount: Single<SingleAccount> {
        Single.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Maybe<StellarWalletAccount> in
                self.accountRepository.initializeMetadataMaybe()
            }
            .asObservable()
            .first()
            .map { account -> StellarWalletAccount in
                guard let account = account else {
                    throw StellarAccountError.noDefaultAccount
                }
                return account
            }
            .map { account -> SingleAccount in
                StellarCryptoAccount(id: account.publicKey, label: account.label, hdAccountIndex: account.index)
            }
    }
    
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let accountRepository: StellarWalletAccountRepository
    private let errorRecorder: ErrorRecording
    private let internalFeatureFlag: InternalFeatureFlagServiceAPI

    init(accountRepository: StellarWalletAccountRepository = resolve(),
         errorRecorder: ErrorRecording = resolve(),
         exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
         internalFeatureFlag: InternalFeatureFlagServiceAPI = resolve()) {
        self.exchangeAccountProvider = exchangeAccountProvider
        self.accountRepository = accountRepository
        self.errorRecorder = errorRecorder
        self.internalFeatureFlag = internalFeatureFlag
    }

    func initialize() -> Completable {
        // Run wallet renaming procedure on initialization.
        nonCustodialGroup.map(\.accounts)
            .flatMapCompletable(weak: self) { (self, accounts) -> Completable in
                self.upgradeLegacyLabels(accounts: accounts)
            }
            .onErrorComplete()
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        guard address.count == 56 else { return .just(nil) }
        guard let pair = try? KeyPair(accountId: address) else { return .just(nil) }
        return .just(
            StellarReceiveAddress(
                address: pair.accountId,
                label: pair.accountId,
                memo: nil,
                onTxCompleted: { _ in Completable.empty() }
            )
        )
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
        return defaultAccount
            .map { account -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: [account])
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
