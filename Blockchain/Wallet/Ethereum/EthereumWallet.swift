//
//  EthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit
import ERC20Kit
import RxSwift
import BigInt

public class EthereumWallet: NSObject {
    typealias Dispatcher = EthereumJSInteropDispatcherAPI & EthereumJSInteropDelegateAPI
    typealias WalletAPI = LegacyEthereumWalletProtocol & MnemonicAccessAPI
    
    @objc public var delegate: EthereumJSInteropDelegateAPI {
        return dispatcher
    }
    
    var interopDispatcher: EthereumJSInteropDispatcherAPI {
        return dispatcher
    }
    
    private weak var wallet: WalletAPI?
    
    private static let defaultPAXAccount = ERC20TokenAccount(
        label: LocalizationConstants.SendAsset.myPaxWallet,
        contractAddress: PaxToken.contractAddress.rawValue,
        hasSeen: "false",
        transactionNotes: [String: String]()
    )
    
    private var secondPassword: String?
    private var ethereumAccountExists: Bool?
    
    private var disposeBag = DisposeBag()
    
    private let dispatcher: Dispatcher
    
    @objc convenience public init(legacyWallet: Wallet) {
        self.init(wallet: legacyWallet)
    }
    
    init(wallet: WalletAPI, dispatcher: Dispatcher = EthereumJSInteropDispatcher.shared) {
        self.wallet = wallet
        self.dispatcher = dispatcher
    }
    
    @objc public func setup(with context: JSContext) {
        context.setJsFunction(named: "objc_on_didGetERC20TokensAsync" as NSString) { [weak self] erc20TokenAccounts in
            self?.delegate.didGetERC20Tokens(erc20TokenAccounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingERC20TokensAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetERC20Tokens(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didSetERC20TokensAsync" as NSString) { [weak self] erc20TokenAccounts in
            self?.delegate.didSaveERC20Tokens()
        }
        context.setJsFunction(named: "objc_on_error_settingERC20TokensAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToSaveERC20Tokens(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_isWaitingOnTransactionAsync" as NSString) { [weak self] isWaiting in
            self?.delegate.didGetIsWaitingOnTransaction(isWaiting)
        }
        context.setJsFunction(named: "objc_on_isWaitingOnTransactionAsync_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetIsWaitingOnTransaction(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_get_ether_address_success" as NSString) { [weak self] address in
            self?.delegate.didGetAddress(address)
        }
        context.setJsFunction(named: "objc_on_get_ether_address_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAddress(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didGetEtherTransactionNonceAsync" as NSString) { [weak self] nonce in
            self?.delegate.didGetNonce(nonce)
        }
        context.setJsFunction(named: "objc_on_error_gettingEtherTransactionNonceAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetNonce(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_getEthTransactionsAsync_success" as NSString) { [weak self] transactions in
            self?.delegate.didGetTransactions(transactions)
        }
        context.setJsFunction(named: "objc_on_getEthTransactionsAsync_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetTransactions(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_get_available_eth_balance_success" as NSString) { [weak self] balance in
            self?.delegate.didGetBalance(balance)
        }
        context.setJsFunction(named: "objc_on_get_available_eth_balance_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetBalance(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_fetch_available_eth_balance_success" as NSString) { [weak self] balance in
            self?.delegate.didFetchBalance(balance)
        }
        context.setJsFunction(named: "objc_on_fetch_available_eth_balance_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToFetchBalance(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_recordLastTransactionAsync_success" as NSString) { [weak self] in
            self?.delegate.didRecordLastTransaction()
        }
        context.setJsFunction(named: "objc_on_recordLastTransactionAsync_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToRecordLastTransaction(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didGetEtherAccountsAsync" as NSString) { [weak self] accounts in
            self?.delegate.didGetAccounts(accounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingEtherAccountsAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAccounts(errorMessage: errorMessage)
        }
    }
    
    @objc public func walletDidLoad() {
        walletLoaded()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    public func walletLoaded() -> Completable {
        guard let wallet = wallet else {
            return Completable.empty()
        }
        ethereumAccountExists = wallet.checkIfEthereumAccountExists()
        return saveDefaultPAXAccountIfNeeded()
    }
    
    private func saveDefaultPAXAccountIfNeeded() -> Completable {
        return erc20TokenAccounts
            .flatMapCompletable(weak: self) { (self, tokenAccounts) -> Completable in
                if tokenAccounts.contains(where: { $0.contractAddress.lowercased() == PaxToken.contractAddress.rawValue.lowercased() }) {
                    return Completable.empty()
                }
                return self.saveDefaultPAXAccount().asCompletable()
            }
    }
    
    private func saveDefaultPAXAccount() -> Single<ERC20TokenAccount> {
        let paxAccount = EthereumWallet.defaultPAXAccount
        return save(erc20TokenAccounts: [ paxAccount ])
            .asObservable()
            .flatMap(weak: self) { (self, _) -> Observable<ERC20TokenAccount> in
                return Observable.just(paxAccount)
            }
            .asSingle()
    }
}

extension EthereumWallet: ERC20BridgeAPI {
    public func save(erc20TokenAccounts: [ERC20TokenAccount]) -> Completable {
        return secondPasswordIfAccountCreationNeeded
            .asObservable()
            .flatMap(weak: self) { (self, secondPassword) -> Observable<Never> in
                return self.save(
                    erc20TokenAccounts: erc20TokenAccounts,
                    secondPassword: secondPassword
                )
                .asObservable()
            }
            .asCompletable()
    }
    
    public var erc20TokenAccounts: Single<[ERC20TokenAccount]> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[ERC20TokenAccount]> in
                self.erc20TokenAccounts(secondPassword: secondPassword)
            }
    }
    
    public func memo(for transactionHash: String, tokenContractAddress: String) -> Single<String?> {
        return erc20TokenAccounts.flatMap(weak: self) { (self, tokenAccounts) -> Single<ERC20TokenAccount?> in
            Single.just(tokenAccounts.first(where: { $0.contractAddress.lowercased() == tokenContractAddress.lowercased() }))
        }
        .map { tokenAccount -> String? in
            tokenAccount?.transactionNotes[transactionHash]
        }
    }
    
    public func save(transactionMemo: String, for transactionHash: String, tokenContractAddress: String) -> Completable {
        return erc20TokenAccounts
            .flatMap(weak: self) { (self, tokenAccounts) -> Single<([ERC20TokenAccount], ERC20TokenAccount)> in
                guard let tokenAccount = tokenAccounts.first(where: { $0.contractAddress.lowercased() == tokenContractAddress.lowercased() }) else {
                    return self.saveDefaultPAXAccount()
                        .flatMap(weak: self) { (self, tokenAccount) -> Single<([ERC20TokenAccount], ERC20TokenAccount)> in
                            Single.just((tokenAccounts + [ tokenAccount ], tokenAccount))
                        }
                }
                return Single.just((tokenAccounts, tokenAccount))
            }
            .asObservable()
            .flatMap(weak: self) { (self, tuple) -> Observable<Never> in
                var (tokenAccounts, tokenAccount) = tuple
                tokenAccount.update(memo: transactionMemo, for: transactionHash)
                tokenAccounts.removeAll(where: {
                    $0.contractAddress.lowercased() == tokenContractAddress.lowercased()
                })
                return self.save(erc20TokenAccounts: tokenAccounts + [ tokenAccount ]).asObservable()
            }
            .asCompletable()
    }
    
    private func save(erc20TokenAccounts: [ERC20TokenAccount], secondPassword: String?) -> Completable {
        return Completable.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            
            var erc20TokensDictionary: [String: ERC20TokenAccount] = [:]
            for token in erc20TokenAccounts {
                erc20TokensDictionary[token.contractAddress] = token
            }
            
            guard let jsonData = try? JSONEncoder().encode(erc20TokensDictionary) else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            wallet.saveERC20Tokens(with: nil, tokensJSONString: jsonData.string, success: {
                observer(.completed)
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
    }
    
    private func erc20TokenAccounts(secondPassword: String? = nil) -> Single<[ERC20TokenAccount]> {
        return Single<[String: [String: Any]]>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.erc20Tokens(with: secondPassword, success: { erc20Tokens in
                observer(.success(erc20Tokens))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap(weak: self) { (self, erc20Accounts) -> Single<[ERC20TokenAccount]> in
            let accounts: [ERC20TokenAccount] = erc20Accounts.decodeJSONValues(type: ERC20TokenAccount.self)
            return Single.just(accounts)
        }
    }
}

extension EthereumWallet: EthereumWalletBridgeAPI, EthereumWalletTransactionsBridgeAPI {
    public var fetchBalance: Single<CryptoValue> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<CryptoValue> in
                return self.fetchBalance(secondPassword: secondPassword)
            }
    }
    
    public var balance: Single<CryptoValue> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<CryptoValue> in
                return self.balance(secondPassword: secondPassword)
            }
    }
    
    public var name: Single<String> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                return self.label(secondPassword: secondPassword)
            }
    }
    
    public var address: Single<String> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                return self.address(secondPassword: secondPassword)
            }
    }
    
    public var transactions: Single<[EthereumHistoricalTransaction]> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[EthereumHistoricalTransaction]> in
                return self.transactions(secondPassword: secondPassword)
            }
    }
    
    public var account: Single<EthereumAssetAccount> {
        return ethereumWallets
            .flatMap { accounts -> Single<EthereumAssetAccount> in
                guard let defaultAccount = accounts.first else {
                    throw WalletError.unknown
                }
                let account = EthereumAssetAccount(
                    walletIndex: 0,
                    accountAddress: defaultAccount.publicKey,
                    name: defaultAccount.label ?? ""
                )
                return Single.just(account)
            }
    }
    
    public var nonce: Single<BigUInt> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<BigUInt> in
                return self.nonce(secondPassword: secondPassword)
            }
    }
    
    public var isWaitingOnEtherTransaction: Single<Bool> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<Bool> in
                return self.isWaitingOnEtherTransaction(secondPassword: secondPassword)
            }
    }
    
    public func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<EthereumTransactionPublished> in
                return self.recordLast(transaction: transaction, secondPassword: secondPassword)
            }
    }
    
    private func fetchBalance(secondPassword: String? = nil) -> Single<CryptoValue> {
        return Single<String>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.fetchEthereumBalance(with: secondPassword, success: { balanceString in
                observer(.success(balanceString))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap { balanceString -> Single<CryptoValue> in
            guard let balance = CryptoValue.etherFromMajor(string: balanceString) else {
                throw WalletError.unknown
            }
            return Single.just(balance)
        }
    }
    
    private func transactions(secondPassword: String? = nil) -> Single<[EthereumHistoricalTransaction]> {
        return Single<[EtherTransaction]>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.getEthereumTransactions(with: secondPassword, success: { transactions in
                observer(.success(transactions))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap { legacyTransactions -> Single<[EthereumHistoricalTransaction]> in
            let transactions: [EthereumHistoricalTransaction] = legacyTransactions
                .map { $0.transaction }
                .compactMap { $0 }
            return Single.just(transactions)
        }
    }
    
    private func accounts(secondPassword: String? = nil) -> Single<EthereumAssetAccount> {
        return ethereumWallets.flatMap { wallets -> Single<EthereumAssetAccount> in
            guard let defaultAccount = wallets.first else {
                throw WalletError.unknown
            }
            let account = EthereumAssetAccount(
                walletIndex: 0,
                accountAddress: defaultAccount.publicKey,
                name: defaultAccount.label ?? ""
            )
            return Single.just(account)
        }
    }
    
    private func balance(secondPassword: String? = nil) -> Single<CryptoValue> {
        return Single<String>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.ethereumBalance(with: secondPassword, success: { balanceString  in
                observer(.success(balanceString))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap { balanceString -> Single<CryptoValue> in
            guard let value = CryptoValue.etherFromMajor(string: balanceString) else {
                throw WalletError.unknown
            }
            return Single.just(value)
        }
    }
    
    private func label(secondPassword: String? = nil) -> Single<String> {
        return Single<String>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.getLabelForEthereumAccount(with: secondPassword, success: { label in
                observer(.success(label))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
    }
    
    private func address(secondPassword: String? = nil) -> Single<String> {
        return Single<String>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.getEthereumAddress(with: secondPassword, success: { address in
                observer(.success(address))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
    }
    
    private func nonce(secondPassword: String? = nil) -> Single<BigUInt> {
        return Single<String>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.getEthereumTransactionNonce(with: secondPassword, success: { nonceString in
                observer(.success(nonceString))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap { nonceString -> Single<BigUInt> in
            guard let value = BigUInt(nonceString, decimals: 0) else {
                return Single.error(WalletError.unknown)
            }
            return Single.just(value)
        }
    }
    
    private func isWaitingOnEtherTransaction(secondPassword: String? = nil) -> Single<Bool> {
        return Single.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.isWaitingOnEthereumTransaction(with: secondPassword, success: { isWaiting in
                observer(.success(isWaiting))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
    }
    
    private func recordLast(transaction: EthereumTransactionPublished, secondPassword: String? = nil) -> Single<EthereumTransactionPublished> {
        return Single.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.recordLastEthereumTransaction(with: secondPassword, transactionHash: transaction.transactionHash, success: {
                observer(.success(transaction))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
    }
}

extension EthereumWallet: MnemonicAccessAPI {
    public var mnemonic: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonic
    }
    
    public var mnemonicForcePrompt: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicForcePrompt
    }
    
    public var mnemonicPromptingIfNeeded: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicPromptingIfNeeded
    }
}

extension EthereumWallet: PasswordAccessAPI {
    public var password: Maybe<String> {
        guard let password = wallet?.password else {
            return Maybe.empty()
        }
        return Maybe.just(password)
    }
}

extension EthereumWallet: EthereumWalletAccountBridgeAPI {
    public func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        guard let base58PrivateKey = keyPair.privateKey.base58EncodedString else {
            return Completable.error(WalletError.failedToSaveKeyPair("Invalid private key"))
        }
        return Completable.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.saveEthereumAccount(with: base58PrivateKey, label: label, success: {
                observer(.completed)
            }, error: { errorMessage in
                observer(.error(WalletError.failedToSaveKeyPair(errorMessage)))
            })
            return Disposables.create()
        })
    }
    
    public var ethereumWallets: Single<[EthereumWalletAccount]> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[EthereumWalletAccount]> in
                return self.ethereumWallets(secondPassword: secondPassword)
            }
    }
    
    private func ethereumWallets(secondPassword: String?) -> Single<[EthereumWalletAccount]> {
        return Single<[[String: Any]]>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.ethereumAccounts(with: secondPassword, success: { accounts in
                observer(.success(accounts))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap(weak: self) { (self, legacyAccounts) -> Single<[EthereumWalletAccount]> in
            let accounts = legacyAccounts
                .decodeJSONObjects(type: LegacyEthereumWalletAccount.self)
                .enumerated()
                .map { index, account -> EthereumWalletAccount in
                    return EthereumWalletAccount(
                        index: index,
                        publicKey: account.addr,
                        label: account.label,
                        archived: false
                    )
                }
            return Single.just(accounts)
        }
    }
    
    private var secondPasswordIfAccountCreationNeeded: Single<String?> {
        return accountExists
            .flatMap(weak: self) { (self, accountExists) -> Single<String?> in
                guard accountExists else {
                    return self.secondPasswordIfNeeded
                }
                return Single.just(nil)
            }
    }
    
    private var accountExists: Single<Bool> {
        guard let ethereumAccountExists = ethereumAccountExists else {
            return Single.error(WalletError.notInitialized)
        }
        return Single.just(ethereumAccountExists)
    }
    
    private var secondPasswordNeeded: Single<Bool> {
        guard let wallet = wallet else {
            return Single.error(WalletError.notInitialized)
        }
        return Single.just(wallet.needsSecondPassword())
    }
    
    private var secondPasswordIfNeeded: Single<String?> {
        return secondPasswordNeeded
            .flatMap(weak: self) { (self, needed) -> Single<String?> in
                guard !needed else {
                    return self.promptForSecondPassword
                        .map { password -> String? in
                            return password
                        }
                }
                return Single.just(nil)
            }
    }
    
    private var promptForSecondPassword: Single<String> {
        return Single.create(subscribe: { observer -> Disposable in
            AuthenticationCoordinator.shared.showPasswordConfirm(
                withDisplayText: LocalizationConstants.Authentication.secondPasswordDefaultDescription,
                headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                validateSecondPassword: true,
                confirmHandler: { password in
                    observer(.success(password))
                },
                dismissHandler: {
                    observer(.error(WalletError.unknown))
                }
            )
            return Disposables.create()
        })
    }
}
