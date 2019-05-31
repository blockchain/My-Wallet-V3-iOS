//
//  SendEthereumService.swift
//  Blockchain
//
//  Created by Jack on 07/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

// TODO: Delete this file once the send PAX screen is implemented (IOS-2065)

import RxSwift
import BigInt
import PlatformKit
import EthereumKit
import ERC20Kit

extension EthereumWalletService {
    public static let shared = EthereumWalletService(
        with: WalletManager.shared.wallet.ethereum,
        ethereumAPIClient: EthereumAPIClient.shared,
        feeService: EthereumFeeService.shared,
        walletAccountRepository: ETHServiceProvider.shared.repository,
        transactionBuildingService: EthereumTransactionBuildingService.shared,
        transactionSendingService: EthereumTransactionSendingService.shared
    )
}

extension EthereumTransactionSendingService {
    static let shared = EthereumTransactionSendingService(
        with: WalletManager.shared.wallet.ethereum,
        ethereumAPIClient: EthereumAPIClient.shared,
        feeService: EthereumFeeService.shared,
        transactionBuilder: EthereumTransactionBuilder.shared,
        transactionSigner: EthereumTransactionSigner.shared
    )
}

extension EthereumTransactionBuildingService {
    static let shared = EthereumTransactionBuildingService(
        with: WalletManager.shared.wallet.ethereum,
        feeService: EthereumFeeService.shared
    )
}

// TODO:
// * Remove this once we implement native PAX send, this is for testing only

#if DEBUG
@objc class SendEthereumService: NSObject {
    
    static let shared = SendEthereumService()
    
    @objc class func sharedInstance() -> SendEthereumService {
        return SendEthereumService.shared
    }
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var toAddress: EthereumAssetAddress?
    private var amountDecimal: Decimal?
    
    private let wallet: Wallet
    private let walletService: EthereumWalletService
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         platformService: EthereumWalletService = EthereumWalletService.shared) {
        self.wallet = wallet
        self.walletService = platformService
    }
    
    @objc func changePayment(to address: String) {
        self.toAddress = EthereumAssetAddress(publicKey: address)
    }
    
    @objc func set(amount: NSDecimalNumber) {
        self.amountDecimal = amount.decimalValue
    }
    
    @objc func send() {
        
        guard
            let toAddress = toAddress,
            let amountDecimal = amountDecimal
        else {
            return
        }
        
        let to = EthereumKit.EthereumAddress(rawValue: toAddress.publicKey)!
        let cryptoValue = CryptoValue.etherFromMajor(decimal: amountDecimal)
        
        guard let ethereumValue = try? EthereumValue(crypto: cryptoValue) else { return }
        
        self.walletService.buildTransaction(with: ethereumValue, to: to)
            .flatMap(weak: self) { (self, tx) -> Single<EthereumTransactionPublished> in
                return self.walletService.send(
                    transaction: tx
                )
            }
            .subscribe(onSuccess: { ethereumTransactionPublished in
                print(ethereumTransactionPublished)
                self.wallet.delegate?.didSendEther?()
            }, onError: { error in
                print(error)
                self.wallet.delegate?.didErrorDuringEtherSend?(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}

@objc class SendPAXService: NSObject {
    
    static let shared = SendPAXService()
    
    @objc class func sharedInstance() -> SendPAXService {
        return SendPAXService.shared
    }
    
    private var to: EthereumKit.EthereumAddress?
    private var amount: CryptoValue?
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    private let wallet: Wallet
    private let walletService: EthereumWalletService
    private let paxService: ERC20Service<PaxToken>
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         platformService: EthereumWalletService = EthereumWalletService.shared,
         paxService: ERC20Service<PaxToken> = PAXServiceProvider.shared.services.paxService) {
        self.wallet = wallet
        self.walletService = platformService
        self.paxService = paxService
    }
    
    @objc func changePayment(to address: String) {
        self.to = EthereumKit.EthereumAddress(rawValue: address)
    }
    
    @objc func set(amount: NSDecimalNumber) {
        self.amount = CryptoValue.paxFromMajor(decimal: amount.decimalValue)
    }
    
    @objc func send() {
        guard let to = to, let amount = amount else {
            return
        }
        
        print("address to: \(to)")
        print("amount.toDisplayString(includeSymbol: false): \(amount.toDisplayString(includeSymbol: false))")

        do {
            let paxAmount = try ERC20TokenValue<PaxToken>(crypto: amount)
            self.paxService.transfer(to: to, amount: paxAmount)
                .flatMap(weak: self) { (self, tx) -> Single<EthereumTransactionPublished> in
                    return self.walletService.send(
                        transaction: tx
                    )
                }
                .subscribe(onSuccess: { [weak self] ethereumTransactionPublished in
                    print(ethereumTransactionPublished)
                    self?.wallet.delegate?.didSendEther?()
                }, onError: { [weak self] error in
                    print(error)
                    self?.wallet.delegate?.didErrorDuringEtherSend?(error.localizedDescription)
                })
                .disposed(by: disposeBag)
        } catch {
            print("error: \(error)")
            Logger.shared.log("Failed to build PAX transaction, error: \(error)", level: .error)
        }
        
    }
}
#endif
