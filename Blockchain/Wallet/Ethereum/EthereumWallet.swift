//
//  EthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import EthereumKit
import PlatformKit
import RxSwift
import BigInt

@objc public protocol LegacyEthereumWalletProtocol {
    var password: String? { get }
    
    func isWaitingOnEtherTransaction() -> Bool
    
    @available(*, deprecated, message: "use recordLastEtherTransaction(with:success:error:) instead")
    func recordLastEtherTransaction(with transactionHash: String)
    func recordLastEtherTransaction(with transactionHash: String, success: @escaping () -> Void, error: @escaping (String?) -> Void)
    
    func getEtherTransactionNonce(success: @escaping (String) -> Void, error: @escaping (String?) -> Void)
    func getEtherAddress(success: @escaping (String) -> Void, error: @escaping (String?) -> Void)
    func getLabelForAccount(_ account: Int32, assetType: LegacyAssetType) -> String!
    
    func fetchEthereumBalance(_ completion: @escaping (String) -> Void, error: @escaping (String) -> Void)
    func getEthBalanceTruncatedNumber() -> NSNumber?
    func getEthTransactions() -> [EtherTransaction]?
}

extension Wallet: LegacyEthereumWalletProtocol {}

extension PlatformKit.Direction {
    var txType: EtherTransaction.TxType {
        switch self {
        case .credit:
            return .received
        case .debit:
            return .sent
        case .transfer:
            return .transfer
        }
    }
}

extension EtherTransaction {
    
    enum TxType: String {
        case sent
        case received
        case transfer
        
        var platformDirection: PlatformKit.Direction {
            switch self {
            case .received:
                return .credit
            case .sent:
                return .debit
            case .transfer:
                return .transfer
            }
        }
    }
    
    convenience init(transaction: EthereumHistoricalTransaction?) {
        self.init()
        
        guard let transaction = transaction else { return }
        
        self.amount = transaction.amount
        self.amountTruncated = EtherTransaction.truncatedAmount(transaction.amount)
        let transactionFee = transaction.fee ?? CryptoValue.etherFromGwei(string: "0")
        self.fee = transactionFee?.toDisplayString(includeSymbol: false)
        self.from = transaction.fromAddress.publicKey
        self.to = transaction.toAddress.publicKey
        self.myHash = transaction.transactionHash
        self.note = transaction.memo
        self.txType = transaction.direction.txType.rawValue
        self.time = UInt64(transaction.createdAt.timeIntervalSince1970)
        self.confirmations = UInt(transaction.confirmations)
        self.fiatAmountsAtTime = [:]
    }
    
    public var transaction: EthereumHistoricalTransaction? {
        return EtherTransaction.mapToTransaction(self)
    }
    
    public static func mapToTransaction(_ legacyTransaction: EtherTransaction) -> EthereumHistoricalTransaction? {
        guard let from = legacyTransaction.from,
            let to = legacyTransaction.to,
            let amount = legacyTransaction.amount,
            let myHash = legacyTransaction.myHash,
            let txType = legacyTransaction.txType else {
            return nil
        }
        
        let fromAddress = EthereumAssetAddress(
            publicKey: from
        )
        
        let toAddress = EthereumAssetAddress(
            publicKey:  to
        )
        
        guard let direction = TxType(rawValue: txType)?.platformDirection,
            let f = legacyTransaction.fee else {
            return nil
        }
        
        // Convert from Ether to GWei
        let feeGwei: Int = NSDecimalNumber(string: f)
            .multiplying(
                byPowerOf10: 9,
                withBehavior: NSDecimalNumberHandler(
                    roundingMode: .bankers,
                    scale: 2,
                    raiseOnExactness: true,
                    raiseOnOverflow: true,
                    raiseOnUnderflow: true,
                    raiseOnDivideByZero: true
                )
            )
            .intValue
        
        return EthereumHistoricalTransaction(
            identifier: myHash,
            fromAddress: fromAddress,
            toAddress: toAddress,
            direction: direction,
            amount: amount,
            transactionHash: myHash,
            createdAt: Date(timeIntervalSince1970: TimeInterval(legacyTransaction.time)),
            fee: CryptoValue.etherFromGwei(string: "\(feeGwei)"),
            memo: legacyTransaction.note,
            confirmations: Int(legacyTransaction.confirmations)
        )
    }
}

extension EthereumHistoricalTransaction {
    var legacyTransaction: EtherTransaction? {
        return EtherTransaction(transaction: self)
    }
}

public class EthereumWallet: NSObject {
    typealias WalletAPI = LegacyEthereumWalletProtocol & MnemonicAccessAPI
    
    private weak var wallet: WalletAPI?
    
    @objc convenience public init(legacyWallet: Wallet) {
        self.init(wallet: legacyWallet)
    }
    
    init(wallet: WalletAPI) {
        self.wallet = wallet
    }
}

extension EthereumWallet: EthereumWalletBridgeAPI, EthereumWalletTransctionsBridgeAPI {
    
    public var fetchBalance: Single<CryptoValue> {
        return Single<String>.create(subscribe: { observer -> Disposable in
            self.wallet?.fetchEthereumBalance({ balance in
                observer(.success(balance))
            }, error: { errorString in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap(weak: self) { (self, balance) -> Single<CryptoValue> in
            guard let balance = Decimal(string: balance) else {
                return self.balance
            }
            return Single.just(
                CryptoValue.createFromMajorValue(
                    balance,
                    assetType: .ethereum
                )
            )
        }
    }
    
    public var balance: Single<CryptoValue> {
        return Single.just(wallet?.getEthBalanceTruncatedNumber())
            .onNil(error: WalletError.notInitialized)
            .flatMap { balance -> PrimitiveSequence<SingleTrait, CryptoValue> in
                let value = CryptoValue.createFromMajorValue(
                    balance.decimalValue,
                    assetType: .ethereum
                )
                return Single.just(value)
            }
    }
    
    public var name: Single<String> {
        // TODO: This value should be read from `wallet.js:EthWallet.defaultAccountIdx()`
        let account: Int32 = 0
        return Single.just(wallet?.getLabelForAccount(account, assetType: .ether))
            .onNil(error: WalletError.notInitialized)
    }
    
    public var address: Single<String> {
        return Single.create(subscribe: { observer -> Disposable in
            self.wallet?.getEtherAddress(success: { address in
                observer(.success(address))
            }, error: { _ in
                observer(.error(WalletError.notInitialized))
            })
            return Disposables.create()
        })
    }
    
    public var transactions: Single<[EthereumHistoricalTransaction]> {
        return Single.create(subscribe: { [weak self] observer -> Disposable in
            guard let legacyTransactions = self?.wallet?.getEthTransactions() else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            let transactions: [EthereumHistoricalTransaction] = legacyTransactions
                .map { $0.transaction }
                .compactMap { $0 }
            observer(.success(transactions))
            return Disposables.create()
        })
    }
    
    public var account: Single<EthereumAssetAccount> {
        return Single.zip(address, name)
            .flatMap { accountAddress, name -> Single<EthereumKit.EthereumAssetAccount> in
                let account = EthereumAssetAccount(
                    walletIndex: 0,
                    accountAddress: accountAddress,
                    name: name
                )
                return Single.just(account)
            }
    }
    
    public var nonce: Single<BigUInt> {
        return Single<String>
            .create(subscribe: { observer -> Disposable in
                self.wallet?.getEtherTransactionNonce(success: { nonceString in
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
    
    public var isWaitingOnEtherTransaction: Single<Bool> {
        let isWaiting = wallet?.isWaitingOnEtherTransaction() ?? true
        return Single.just(isWaiting)
    }
    
    public func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        // TODO:
        // * Move to async method once My-Wallet-V3 is updated to be done as part of:
        //   https://blockchain.atlassian.net/browse/IOS-2193
        wallet?.recordLastEtherTransaction(with: transaction.transactionHash)
        return Single.just(transaction).delay(0.1, scheduler: MainScheduler.asyncInstance)
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
    
    // TODO:
    // * Implement `EthereumWalletAccountBridgeAPI`
    public func save(keyPair: EthereumKeyPair, label: String) -> Single<String> {
        fatalError("Not yet implemented")
    }

    public var ethereumWallets: Single<[EthereumWalletAccount]> {
        fatalError("Not yet implemented")
    }
}
