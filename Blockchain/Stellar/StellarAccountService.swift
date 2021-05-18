//
//  StellarAccountService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import PlatformKit
import RxCocoa
import RxSwift
import StellarKit
import stellarsdk

class StellarAccountService: StellarAccountAPI {

    typealias StellarTransaction = stellarsdk.Transaction

    // MARK: AccountBalanceFetching
    
    var accountType: SingleAccountType {
        .nonCustodial
    }
    
    var balance: Single<CryptoValue> {
        currentStellarAccount(fromCache: false)
            .flatMap(weak: self) { (self, account) -> Single<CryptoValue> in
                Single.just(account.assetAccount.balance)
            }
            .catchError { (error) -> Single<CryptoValue> in
                guard error is StellarAccountError else { return Single.error(error) }
                return Single.just(.zero(currency: .stellar))
            }
    }
    
    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .stellar))
    }
    
    var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }
    
    var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }

    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.map { MoneyValue(cryptoValue: $0) }
    }
    
    private let balanceRelay = PublishRelay<CryptoValue>()
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    private var disposable: Disposable?
    
    private var service: Single<AccountService> {
        sdk.map { $0.accounts }
    }

    private var sdk: Single<stellarsdk.StellarSDK> {
        configuration.map { $0.sdk }
    }
    
    private var configuration: Single<StellarConfiguration> {
        configurationService.configuration
    }
    
    private let configurationService: StellarConfigurationAPI
    private let ledgerService: StellarLedgerServiceAPI
    private let repository: StellarWalletAccountRepositoryAPI
    private let walletOptionsAPI: WalletOptionsAPI

    init(
        configurationService: StellarConfigurationAPI,
        ledgerService: StellarLedgerServiceAPI,
        repository: StellarWalletAccountRepositoryAPI,
        walletService: WalletOptionsAPI = resolve()
    ) {
        self.configurationService = configurationService
        self.ledgerService = ledgerService
        self.repository = repository
        self.walletOptionsAPI = walletService
                
        balanceFetchTriggerRelay
            .flatMapLatest(weak: self) { (self, _) in
                self.balance.asObservable()
            }
            .catchErrorJustReturn(CryptoValue.stellarZero)
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
    
    var currentAccount: StellarAccount? {
        privateAccount.value
    }
    
    fileprivate var privateAccount = BehaviorRelay<StellarAccount?>(value: nil)
    
    // MARK: Private Functions
    
    fileprivate func defaultXLMAccount() -> StellarWalletAccount? {
        repository.defaultAccount
    }
    
    // MARK: Public Functions
    
    func clear() {
        privateAccount = BehaviorRelay<StellarAccount?>(value: nil)
    }

    func prefetch() {
        disposable = currentStellarAccount(fromCache: true).subscribe()
    }
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount> {
        Maybe.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Maybe<StellarAccount> in
                if let cached = self.privateAccount.value, fromCache == true {
                    return Maybe.just(cached)
                }
                guard let XLMAccount = self.defaultXLMAccount() else {
                    return Maybe.error(StellarAccountError.noXLMAccount)
                }
                let accountID = XLMAccount.publicKey
                return self.accountDetails(for: accountID)
                    .do(onNext: { [weak self] account in
                        self?.privateAccount.accept(account)
                    })
            }
    }
    
    func currentStellarAccountAsSingle(fromCache: Bool) -> Single<StellarAccount?> {
        currentStellarAccount(fromCache: fromCache)
            .asObservable()
            .materialize()
            /// Map `completed` event into `.next(nil)` in order to convert later to `Single`.
            .map { event -> Event<StellarAccount?> in
                switch event {
                case .next(let account):
                    return .next(account)
                case .error(let error):
                    return .error(error)
                case .completed:
                    return .next(nil)
                }
            }
            .dematerialize()
            /// Only take the first - make sure that success will
            /// be streamed right after the first element.
            .take(1)
            .asSingle()
    }

    func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        service.flatMap(weak: self) { (self, service) -> Single<AccountResponse> in
            Single<AccountResponse>.create { event -> Disposable in
                service.getAccountDetails(accountId: accountID, response: { response -> (Void) in
                    switch response {
                    case .success(details: let details):
                        event(.success(details))
                    case .failure(error: let error):
                        event(.error(error.toStellarServiceError()))
                    }
                })
                return Disposables.create()
            }
        }
    }
    
    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        accountResponse(for: accountID).map { details -> StellarAccount in
            details.toStellarAccount()
        }.catchError { error in
            // If the network call to Horizon fails due to there not being a default account (i.e. account is not yet
            // funded), catch that error and return a StellarAccount with 0 balance
            if let stellarError = error as? StellarAccountError, stellarError == .noDefaultAccount {
                return Single.just(StellarAccount.unfundedAccount(accountId: accountID))
            }
            throw error
        }.asMaybe()
    }
    
    func fundAccount(
        _ accountID: AccountID,
        amount: Decimal,
        sourceKeyPair: StellarKit.StellarKeyPair
    ) -> Completable {
        ledgerService.current.take(1)
            .asSingle()
            .flatMapCompletable { [weak self] ledger -> Completable in
                guard let strongSelf = self else {
                    return Completable.empty()
                }
                guard let baseReserveInXlm = ledger.baseReserveInXlm else {
                    return Completable.empty()
                }
                guard let amountCrypto = CryptoValue.stellar(major: (amount as NSDecimalNumber).description(withLocale: Locale.Posix)) else {
                    return Completable.empty()
                }
                guard amountCrypto.amount >= baseReserveInXlm.amount * 2 else {
                    return Completable.error(StellarFundsError.insufficientFundsForNewAccount)
                }
                return strongSelf.accountResponse(for: sourceKeyPair.accountID)
                    .flatMapCompletable { [weak self] sourceAccountResponse -> Completable in
                        guard let strongSelf = self else {
                            return Completable.never()
                        }
                        return strongSelf.fundAccountCompletable(
                            accountID,
                            amount: amount,
                            sourceAccountResponse: sourceAccountResponse,
                            sourceKeyPair: sourceKeyPair
                        )
                    }
            }
    }

    private func fundAccountCompletable(
        _ accountID: AccountID,
        amount: Decimal,
        sourceAccountResponse: AccountResponse,
        sourceKeyPair: StellarKit.StellarKeyPair
    ) -> Completable {
        configuration.flatMap(weak: self) { (self, configuration) -> Single<Void> in
            Single.create(subscribe: { event -> Disposable in
                do {
                    // Build operation
                    let source = try KeyPair(secretSeed: sourceKeyPair.secret)
                    let destination = try KeyPair(accountId: accountID)
                    let createAccount = CreateAccountOperation(
                        sourceAccount: nil,
                        destination: destination,
                        startBalance: amount
                    )

                    // Build the transaction
                    let transaction = try StellarTransaction(
                        sourceAccount: sourceAccountResponse,
                        operations: [createAccount],
                        memo: Memo.none,
                        timeBounds: nil
                    )

                    // Sign the transaction
                    try transaction.sign(keyPair: source, network: configuration.network)
    
                    // Submit the transaction
                    try configuration.sdk.transactions
                        .submitTransaction(transaction: transaction, response: { response -> (Void) in
                            switch response {
                            case .success(details: _):
                                event(.success(()))
                            case .failure(let error):
                                event(.error(error))
                            case .destinationRequiresMemo:
                                event(.error(HorizonRequestError.requestFailed(message: "Requires Memo")))
                            }
                        })
                } catch {
                    event(.error(error))
                }
                return Disposables.create()
            })
        }
        .asCompletable()
    }

    func validate(accountID: AccountID) -> Single<Bool> {
        guard accountID.count > 0,
            let _ = try? KeyPair(accountId: accountID) else {
            return Single.just(false)
        }
        return Single.just(true)
    }
    
    func isExchangeAddress(_ address: AccountID) -> Single<Bool> {
        walletOptionsAPI.walletOptions.map { walletOptions in
            let result = walletOptions.xlmExchangeAddresses?.contains(where: { $0.uppercased() == address.uppercased() }) ?? false
            return result
        }
    }
}

// MARK: - Extension

extension AccountResponse {
    func toStellarAccount() -> StellarAccount {
        let totalBalanceDecimal = balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
        let totalBalance = CryptoValue.stellar(major: (totalBalanceDecimal as NSDecimalNumber).description(withLocale: Locale.Posix)) ?? CryptoValue.stellarZero
        let assetAddress = AssetAddressFactory.create(
            fromAddressString: accountId,
            assetType: .stellar
        )
        let assetAccount = AssetAccount(
            index: 0,
            address: assetAddress,
            balance: totalBalance,
            name: CryptoCurrency.stellar.defaultWalletName
        )
        return StellarAccount(
            identifier: accountId,
            assetAccount: assetAccount,
            sequence: sequenceNumber,
            subentryCount: subentryCount
        )
    }
}
