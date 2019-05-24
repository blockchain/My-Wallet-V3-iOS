//
//  LegacyEthereumWalletMock.swift
//  BlockchainTests
//
//  Created by Jack on 26/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
@testable import PlatformKit
@testable import EthereumKit
@testable import PlatformUIKit
@testable import Blockchain

class MockLegacyEthereumWallet: LegacyEthereumWalletProtocol, MnemonicAccessAPI {

    enum MockLegacyEthereumWalletError: Error {
        case notInitialized
        case unknown
    }
    
    var password: String? = "password"
    
    var getEtherTransactionNonceCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success("1")
    func getEtherTransactionNonce(success: @escaping (String) -> Void, error: @escaping (String?) -> Void) {
        switch getEtherTransactionNonceCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    
    var getEtherAddressCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success("address")
    func getEtherAddress(success: @escaping (String) -> Void, error: @escaping (String?) -> Void) {
        switch getEtherAddressCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var labelForAccount: String?
    func getLabelForAccount(_ account: Int32, assetType: LegacyAssetType) -> String! {
        return labelForAccount ?? "account: \(account), assetType: \(assetType.rawValue)"
    }
    
    var getEthBalanceTruncatedNumberValue: NSNumber? = NSNumber(value: 1337)
    func getEthBalanceTruncatedNumber() -> NSNumber? {
        return getEthBalanceTruncatedNumberValue
    }
    
    var ethTransactions: [EtherTransaction]? = [
        EthereumHistoricalTransaction(
            identifier: "identifier",
            fromAddress: EthereumHistoricalTransaction.Address(publicKey: "fromAddress.publicKey"),
            toAddress: EthereumHistoricalTransaction.Address(publicKey: "toAddress.publicKey"),
            direction: .credit,
            amount: "amount",
            transactionHash: "transactionHash",
            createdAt: Date(),
            fee: CryptoValue.etherFromGwei(string: "1"),
            memo: "memo",
            confirmations: 12
        ).legacyTransaction
    ].compactMap { $0 }
    func getEthTransactions() -> [EtherTransaction]? {
        return ethTransactions
    }
    
    var isWaitingOnEtherTransactionValue: Bool = false
    func isWaitingOnEtherTransaction() -> Bool {
        return isWaitingOnEtherTransactionValue
    }
    
    var lastRecordedEtherTransactionHash: String?
    func recordLastEtherTransaction(with transactionHash: String) {
        lastRecordedEtherTransactionHash = transactionHash
    }
    
    var lastRecordedEtherTransactionHashAsync: String?
    var recordLastEtherTransactionAsyncCompletion: NewResult<Void, MockLegacyEthereumWalletError> = .success(())
    func recordLastEtherTransaction(with transactionHash: String, success: @escaping () -> Void, error: @escaping (String?) -> Void) {
        lastRecordedEtherTransactionHashAsync = transactionHash
        switch recordLastEtherTransactionAsyncCompletion {
        case .success:
            success()
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var fetchEthereumBalanceCalled: Bool = false
    var fetchEthereumBalancecCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success("")
    func fetchEthereumBalance(_ completion: ((String) -> Void)!, error: @escaping (String) -> Void) {
        fetchEthereumBalanceCalled = true
        switch fetchEthereumBalancecCompletion {
        case .success(let value):
            completion(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    // MARK: - MnemonicAccessAPI
    
    var mnemonicMaybe = Maybe.just("")
    var mnemonic: Maybe<String> {
        return mnemonicMaybe
    }
    
    var mnemonicForcePromptMaybe = Maybe.just("")
    var mnemonicForcePrompt: Maybe<String> {
        return mnemonicForcePromptMaybe
    }
    
    var mnemonicPromptingIfNeededMaybe = Maybe.just("")
    var mnemonicPromptingIfNeeded: Maybe<String> {
        return mnemonicPromptingIfNeededMaybe
    }
}


