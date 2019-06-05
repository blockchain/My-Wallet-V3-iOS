//
//  AssetAccountRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformKit
import ERC20Kit

/// A repository for `AssetAccount` objects
// TICKET: [IOS-2087] - Integrate PlatformKit Account Repositories
// and Deprecate AssetAccountRepository
class AssetAccountRepository {

    static let shared = AssetAccountRepository()

    private let wallet: Wallet
    private let xlmServiceProvider: XLMServiceProvider
    private let paxAccountRepository: ERC20AssetAccountRepository<PaxToken>
    private let stellarAccountService: StellarAccountAPI
    private var cachedAccounts = BehaviorRelay<[AssetAccount]?>(value: nil)
    private let disposables = CompositeDisposable()

    init(
        wallet: Wallet = WalletManager.shared.wallet,
        xlmServiceProvider: XLMServiceProvider = XLMServiceProvider.shared,
        paxServiceProvider: PAXServiceProvider = PAXServiceProvider.shared
    ) {
        self.wallet = wallet
        self.paxAccountRepository = paxServiceProvider.services.assetAccountRepository
        self.xlmServiceProvider = xlmServiceProvider
        self.stellarAccountService = xlmServiceProvider.services.accounts
    }

    deinit {
        disposables.dispose()
    }

    // MARK: Public Methods
    
    func accounts(for assetType: AssetType, fromCache: Bool = true) -> Maybe<[AssetAccount]> {
        // A crash occurs in the for loop if wallet.getActiveAccountsCount returns 0
        // "Fatal error: Can't form Range with upperBound < lowerBound"
        if !wallet.isInitialized() {
            return Maybe.empty()
        }
        
        if assetType == .pax {
            return paxAccountRepository.assetAccountDetails.flatMap {
                let account = AssetAccount(
                    index: 0,
                    address: AssetAddressFactory.create(
                        fromAddressString: $0.account.accountAddress,
                        assetType: .pax
                    ),
                    balance: $0.balance.majorValue,
                    name: "My USD PAX Wallet"
                )
                return Maybe.just([account])
            }
        }
        
        if fromCache {
            return accounts.asMaybe().flatMap { result -> Maybe<[AssetAccount]> in
                let cached = result.filter({ $0.address.assetType == assetType })
                return Maybe.just(cached)
            }
        }
        
        if assetType == .ethereum {
            return defaultEthereumAccount().flatMap({
                return Maybe.just([$0])
            })
        }
        
        if assetType == .stellar {
            if fromCache == false {
                return stellarAccountService.currentStellarAccount(fromCache: false).map({ return [$0.assetAccount] })
            }
            if let stellarAccount = defaultStellarAccount() {
                return Maybe.just([stellarAccount])
            }
            
            return Maybe.empty()
        }
        
        // Handle BTC and BCH
        // TODO pull in legacy addresses.
        // TICKET: IOS-1290
        var result: [AssetAccount] = []
        for index in 0...wallet.getActiveAccountsCount(assetType.legacy)-1 {
            let index = wallet.getIndexOfActiveAccount(index, assetType: assetType.legacy)
            if let assetAccount = AssetAccount.create(assetType: assetType, index: index, wallet: wallet) {
                result.append(assetAccount)
            }
        }
        return Maybe.just(result)
    }
    
    var accounts: Observable<[AssetAccount]> {
        guard let value = cachedAccounts.value else {
            return fetchAccounts().asObservable()
        }
        return Observable.just(value)
    }

    func fetchAccounts() -> Single<[AssetAccount]> {
        var observables: [Observable<[AssetAccount]>] = []
        AssetType.all.forEach {
            let observable = accounts(for: $0, fromCache: false)
                .ifEmpty(default: [])
                .asObservable()
            observables.append(observable)
        }
        return Single.create { observer -> Disposable in
            let disposable = Observable.zip(observables)
                .subscribeOn(MainScheduler.asyncInstance)
                .map({ $0.flatMap({ return $0 })})
                .subscribe(onNext: { [weak self] output in
                    guard let self = self else { return }
                    self.cachedAccounts.accept(output)
                    observer(.success(output))
                })
            self.disposables.insertWithDiscardableResult(disposable)
            return Disposables.create()
        }
    }

    func defaultAccount(for assetType: AssetType, fromCache: Bool = true) -> Maybe<AssetAccount> {
        if assetType == .ethereum {
            return defaultEthereumAccount()
        } else if assetType == .stellar {
            if let account = defaultStellarAccount() {
                return Maybe.just(account)
            } else {
                return Maybe.empty()
            }
        }
        let index = wallet.getDefaultAccountIndex(for: assetType.legacy)
        let account = AssetAccount.create(assetType: assetType, index: index, wallet: wallet)
        if let result = account {
            return Maybe.just(result)
        } else {
            return Maybe.empty()
        }
    }

    func defaultEthereumAccount() -> Maybe<AssetAccount> {
        return Maybe.create(subscribe: { [weak self] observer -> Disposable in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }
            
            guard let ethereumAddress = self.wallet.getEtherAddress(), self.wallet.hasEthAccount() else {
                Logger.shared.debug("This wallet has no ethereum address.")
                observer(.completed)
                return Disposables.create()
            }
            
            self.wallet.fetchEthereumBalance(with: nil, success: { balance in
                let account = AssetAccount(
                    index: 0,
                    address: AssetAddressFactory.create(fromAddressString: ethereumAddress, assetType: .ethereum),
                    balance: Decimal(string: balance) ?? 0,
                    name: LocalizationConstants.myEtherWallet
                )
                observer(.success(account))
            }, error: { error in
                Logger.shared.error(error)
                let account = AssetAccount(
                    index: 0,
                    address: AssetAddressFactory.create(fromAddressString: ethereumAddress, assetType: .ethereum),
                    balance: 0,
                    name: LocalizationConstants.myEtherWallet
                )
                observer(.success(account))
            })
            
            return Disposables.create()
        })
    }

    func defaultStellarAccount() -> AssetAccount? {
        guard let stellarAccount = stellarAccountService.currentAccount else {
            return nil
        }
        return stellarAccount.assetAccount
    }
}

extension AssetAccount {

    /// Creates a new AssetAccount. This method only supports creating an AssetAccount for
    /// BTC or BCH. For ETH, use `defaultEthereumAccount`.
    static func create(assetType: AssetType, index: Int32, wallet: Wallet) -> AssetAccount? {
        guard let address = wallet.getReceiveAddress(forAccount: index, assetType: assetType.legacy) else {
            return nil
        }
        let name = wallet.getLabelForAccount(index, assetType: assetType.legacy)
        let balanceFromWalletObject = wallet.getBalanceForAccount(index, assetType: assetType.legacy)
        let balance: Decimal
        if assetType == .bitcoin || assetType == .bitcoinCash {
            let balanceLong = balanceFromWalletObject as? CUnsignedLongLong ?? 0
            balance = Decimal(balanceLong) / Decimal(Constants.Conversions.satoshi)
        } else {
            let balanceString = balanceFromWalletObject as? String ?? "0"
            balance = NSDecimalNumber(string: balanceString).decimalValue
        }
        return AssetAccount(
            index: index,
            address: AssetAddressFactory.create(fromAddressString: address, assetType: assetType),
            balance: balance,
            name: name ?? ""
        )
    }
}

extension AssetAccountRepository {
    
    fileprivate func fetchAccountsStartingWithCache(
        cachedValue: BehaviorRelay<[AssetAccount]?>,
        networkValue: Single<[AssetAccount]>
        ) -> Observable<[AssetAccount]> {
        let networkObservable = networkValue.asObservable()
        guard let cached = cachedValue.value else {
            return networkObservable
        }
        return networkObservable.startWith(cached)
    }
    
    func nameOfAccountContaining(address: String) -> Maybe<String> {
        return accounts.asSingle().flatMapMaybe { output -> Maybe<String> in
            guard let result = output.first(where: { $0.address.address == address }) else {
                return Maybe.empty()
            }
            return Maybe.just(result.name)
        }
    }
}
