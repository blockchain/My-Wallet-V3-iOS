//
//  BitcoinWallet.swift
//  Blockchain
//
//  Created by Jack on 12/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import BitcoinKit
import Foundation
import JavaScriptCore
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

final class BitcoinWallet: NSObject {
    
    fileprivate struct TransactionAmounts {
        let finalFee: MoneyValue
        let sweepAmount: MoneyValue
        let sweepFee: MoneyValue
    }
    
    typealias Dispatcher = BitcoinJSInteropDispatcherAPI & BitcoinJSInteropDelegateAPI
    typealias WalletAPI = LegacyBitcoinWalletProtocol & LegacyWalletAPI & MnemonicAccessAPI
    
    @objc public var delegate: BitcoinJSInteropDelegateAPI {
        dispatcher
    }
    
    var interopDispatcher: BitcoinJSInteropDispatcherAPI {
        dispatcher
    }

    weak var reactiveWallet: ReactiveWalletAPI!

    private lazy var credentialsProvider: WalletCredentialsProviding = WalletManager.shared.legacyRepository
    private weak var wallet: WalletAPI?
    private let dispatcher: Dispatcher
    
    @objc convenience public init(legacyWallet: Wallet) {
        self.init(wallet: legacyWallet)
    }
    
    init(wallet: WalletAPI,
         dispatcher: Dispatcher = BitcoinJSInteropDispatcher.shared) {
        self.wallet = wallet
        self.dispatcher = dispatcher
    }
    
    @objc public func setup(with context: JSContext) {
        
        context.setJsFunction(named: "objc_on_didGetDefaultBitcoinWalletIndexAsync" as NSString) { [weak self] defaultWalletIndex in
            self?.delegate.didGetDefaultWalletIndex(defaultWalletIndex)
        }
        context.setJsFunction(named: "objc_on_error_gettingDefaultBitcoinWalletIndexAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetDefaultWalletIndex(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didGetBitcoinWalletIndexAsync" as NSString) { [weak self] defaultWalletIndex in
            self?.delegate.didGetWalletIndex(defaultWalletIndex)
        }
        context.setJsFunction(named: "objc_on_error_gettingBitcoinWalletIndexAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetDefaultWalletIndex(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didGetBitcoinWalletsAsync" as NSString) { [weak self] accounts in
            self?.delegate.didGetAccounts(accounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingBitcoinWalletsAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAccounts(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didGetHDWalletAsync" as NSString) { [weak self] wallet in
            self?.delegate.didGetHDWallet(wallet)
        }
        context.setJsFunction(named: "objc_on_error_gettingHDWalletAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetHDWallet(errorMessage: errorMessage)
        }
    }
}

extension BitcoinWallet: BitcoinChainSendBridgeAPI {
    func buildProposal<Token>(with destination: BitcoinChainReceiveAddress<Token>,
                              amount: MoneyValue,
                              fees: MoneyValue,
                              source: CryptoAccount) -> Single<BitcoinChainTransactionProposal<Token>> where Token : BitcoinChainToken {
        source
            .receiveAddress
            .map { $0 as! BitcoinChainReceiveAddress<Token> }
            .map(\.index)
            .map { index -> BitcoinChainTransactionProposal<Token> in
                .init(destination: destination,
                      amount: amount,
                      fees: fees,
                      walletIndex: index,
                      source: source)
            }
    }
    
    func buildCandidate<Token>(with proposal: BitcoinChainTransactionProposal<Token>) -> Single<BitcoinChainTransactionCandidate<Token>> {
        func buildCandidate(
            with legacyOrderCandidate: OrderTransactionLegacy
        ) -> Single<BitcoinChainTransactionCandidate<Token>> {
            Single.create(weak: self) { (self, observer) -> Disposable in
                self.wallet?.createOrderPayment(
                    withOrderTransaction: legacyOrderCandidate,
                    completion: {
                        // NOTE: No-op
                    },
                    success: { json in
                        let amounts = Self.extractAmounts(
                            from: json,
                            cryptoCurrency: Token.coin.cryptoCurrency
                        )
                        let candidate = BitcoinChainTransactionCandidate<Token>(
                            proposal: proposal,
                            fees: amounts.finalFee,
                            sweepAmount: amounts.sweepAmount,
                            sweepFee: amounts.sweepFee
                        )
                        observer(.success(candidate))
                    },
                    error: { json in
                        Logger.shared.error("BTC Candidate build failure: \(json)")
                        /// NOTE: This error is mapped from the value that is returned from JS.
                        /// It's possible this error is not important and we always want to return
                        /// `.insufficientFunds`. However, we may want a different
                        ///  `TransactionValidationFailure.State` in the event that the user has the funds
                        /// but cannot cover fees.
                        let amounts = Self.extractAmounts(
                            from: json,
                            cryptoCurrency: Token.coin.cryptoCurrency
                        )
                        let errorMessage = json["error"] as? String ?? ""
                        let transactionError = BitcoinChainTransactionError(
                            stringValue: errorMessage,
                            finalFee: amounts.finalFee,
                            sweepAmount: amounts.sweepAmount,
                            sweepFee: amounts.sweepFee
                        )
                        return observer(.error(transactionError))
                    }
                )
                return Disposables.create()
            }
        }
        let legacyOrderCandidate = OrderTransactionLegacy(
            legacyAssetType: Token.coin.cryptoCurrency.legacy,
            from: proposal.walletIndex,
            to: proposal.destination.address,
            amount: proposal.amount.toDisplayString(includeSymbol: false),
            fees: proposal.fees.toDisplayString(includeSymbol: false),
            gasLimit: nil
        )
        return Single.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap { _ -> Single<BitcoinChainTransactionCandidate<Token>> in
                buildCandidate(with: legacyOrderCandidate)
            }
    }

    static private func extractAmounts(
        from json: [AnyHashable: Any],
        cryptoCurrency: CryptoCurrency
    ) -> TransactionAmounts {
        let paymentJSON: [AnyHashable: Any] = json["payment"] as? [AnyHashable: Any] ?? [:]

        let finalFeeAny: Any = paymentJSON["finalFee"] ?? ""
        guard let finalFee = CryptoValue.create(minor: "\(finalFeeAny)", currency: cryptoCurrency) else {
            fatalError("We should always have a finalFee")
        }

        let sweepAmountAny: Any = paymentJSON["sweepAmount"] ?? ""
        let sweepAmount = CryptoValue.create(minor: "\(sweepAmountAny)", currency: cryptoCurrency) ?? .zero(currency: cryptoCurrency)

        let sweepFeeAny: Any = paymentJSON["sweepFee"] ?? ""
        let sweepFee = CryptoValue.create(minor: "\(sweepFeeAny)", currency: cryptoCurrency) ?? .zero(currency: cryptoCurrency)

        return TransactionAmounts(
            finalFee: finalFee.moneyValue,
            sweepAmount: sweepAmount.moneyValue,
            sweepFee: sweepFee.moneyValue
        )
    }
    
    func send(coin: BitcoinChainCoin, with secondPassword: String?) -> Single<String> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            self.wallet?.sendOrderTransaction(
                coin.cryptoCurrency.legacy,
                secondPassword: secondPassword,
                completion: {
                    // no-op
                },
                success: { transactionHash in
                    observer(.success(transactionHash))
                },
                error: { messsage in
                    observer(.error(PlatformKitError.illegalStateException(message: messsage)))
                },
                cancel: {
                    observer(.error(PlatformKitError.default))
                })
            return Disposables.create()
        }
    }
}

extension BitcoinWallet: BitcoinWalletBridgeAPI {
    
    func walletIndex(for receiveAddress: String) -> Single<Int32> {
        Single<Int32>.create(weak: self) { (self, observer) -> Disposable in
            guard let wallet = self.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            
            wallet.bitcoinWalletIndex(receiveAddress: receiveAddress, success: { walletIndex in
                observer(.success(walletIndex))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        }
    }

    func receiveAddress(forXPub xpub: String) -> Single<String> {
        reactiveWallet
            .waitUntilInitializedSingle
            .map(weak: self) { (self, _) -> String in
                guard let wallet = self.wallet else {
                    fatalError("Wallet was nil")
                }
                let result = wallet.getBitcoinReceiveAddress(forXPub: xpub)
                switch result {
                case .success(let address):
                    return address
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
    }

    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        let saveMemo: Completable = Completable.create { completable in
            self.wallet?.saveBitcoinMemo(for: transactionHash, memo: memo)
            completable(.completed)
            return Disposables.create()
        }
        return reactiveWallet
            .waitUntilInitialized
            .flatMap { saveMemo.asObservable() }
            .asCompletable()
    }

    func memo(for transactionHash: String) -> Single<String?> {
        let memo: Single<String?> = Single
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    return Disposables.create()
                }
                wallet.getBitcoinMemo(
                    for: transactionHash,
                    success: { (memo) in
                        observer(.success(memo))
                    },
                    error: { (error) in
                        observer(.error(WalletError.unknown))
                    }
                )
                return Disposables.create()
            }

        return reactiveWallet
            .waitUntilInitializedSingle
            .flatMap { memo }
    }
    
    func validateBitcoin(address: String) -> Bool {
        guard let wallet = wallet else { return false }
        return wallet.validateBitcoin(address: address)
    }

    var hdWallet: Single<PayloadBitcoinHDWallet> {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) -> Single<String?> in
                self.secondPasswordIfAccountCreationNeeded
            }
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                self.hdWallet(secondPassword: secondPassword)
            }
            .map(weak: self) { (self, hdWalletString) -> PayloadBitcoinHDWallet in
                guard let data = hdWalletString.data(using: .utf8) else {
                    throw WalletError.unknown
                }
                return try JSONDecoder().decode(PayloadBitcoinHDWallet.self, from: data)
            }
    }

    var defaultWallet: Single<BitcoinWalletAccount> {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) -> Single<String?> in
                self.secondPasswordIfAccountCreationNeeded
            }
            .flatMap(weak: self) { (self, secondPassword) -> Single<BitcoinWalletAccount> in
                self.defaultWallet(secondPassword: secondPassword)
            }
    }

    private func defaultWallet(secondPassword: String?) -> Single<BitcoinWalletAccount> {
        bitcoinWallets(secondPassword: secondPassword)
            .flatMap { wallets -> Single<BitcoinWalletAccount> in
                self.defaultWalletIndex(secondPassword: secondPassword)
                    .map { index -> BitcoinWalletAccount in
                        guard let defaultWallet = wallets[safe: index] else {
                            throw WalletError.unknown
                        }
                        return defaultWallet
                    }
            }
    }

    var wallets: Single<[BitcoinWalletAccount]> {
        secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[BitcoinWalletAccount]> in
                self.bitcoinWallets(secondPassword: secondPassword)
            }
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    private func bitcoinWallets(secondPassword: String?) -> Single<[BitcoinWalletAccount]> {
        bitcoinLegacyWallets(secondPassword: secondPassword)
            .flatMap(weak: self) { (self, legacyWallets) -> Single<[BitcoinWalletAccount]> in
                guard let data = legacyWallets.data(using: .utf8) else {
                    throw WalletError.unknown
                }
                let decodedLegacyWallets: [PayloadBitcoinWalletAccount]
                do {
                    decodedLegacyWallets = try JSONDecoder().decode([PayloadBitcoinWalletAccount].self, from: data)
                } catch {
                    throw error
                }
                let decodedWallets = decodedLegacyWallets
                    .enumerated()
                    .map { (index, legacyAccount) -> BitcoinWalletAccount in
                        BitcoinWalletAccount(
                            index: index,
                            publicKey: legacyAccount.xpub,
                            label: legacyAccount.label,
                            archived: legacyAccount.archived
                        )
                    }
                return Single.just(decodedWallets)
            }
    }

    private func bitcoinLegacyWallets(secondPassword: String?) -> Single<String> {
        Single<String>.create(weak: self) { (self, observer) -> Disposable in
            guard let wallet = self.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.bitcoinWallets(
                with: secondPassword,
                success: { accounts in observer(.success(accounts)) },
                error: { errorMessage in observer(.error(WalletError.unknown)) }
            )
            return Disposables.create()
        }
    }
    
    private func hdWallet(secondPassword: String?) -> Single<String> {
        Single<String>.create(weak: self) { (self, observer) -> Disposable in
            guard let wallet = self.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.hdWallet(
                with: secondPassword,
                success: { wallet in observer(.success(wallet)) },
                error: { errorMessage in observer(.error(WalletError.unknown)) }
            )
            return Disposables.create()
        }
    }
    
    private func defaultWalletIndex(secondPassword: String?) -> Single<Int> {
        Single<Int>.create(weak: self) { (self, observer) -> Disposable in
            guard let wallet = self.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.bitcoinDefaultWalletIndex(
                with: secondPassword,
                success: { defaultWalletIndex in
                    observer(.success(defaultWalletIndex))
                },
                error: { errorMessage in
                    observer(.error(WalletError.unknown))
                }
            )
            return Disposables.create()
        }
    }
}

extension BitcoinWallet: SecondPasswordPromptable {
    var legacyWallet: LegacyWalletAPI? {
        wallet
    }
    
    var accountExists: Single<Bool> {
        Single.just(true)
    }
}

extension BitcoinWallet: PasswordAccessAPI {
    public var password: Maybe<String> {
        guard let password = credentialsProvider.legacyPassword else {
            return Maybe.empty()
        }
        return Maybe.just(password)
    }
}

extension BitcoinWallet: MnemonicAccessAPI {
    var mnemonic: Maybe<Mnemonic> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonic
    }
    
    var mnemonicForcePrompt: Maybe<Mnemonic> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicForcePrompt
    }
    
    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicPromptingIfNeeded
    }

    func mnemonic(with secondPassword: String?) -> Single<Mnemonic> {
        guard let wallet = wallet else {
            return .error(PlatformKitError.default)
        }
        return wallet.mnemonic(with: secondPassword)
    }
}
