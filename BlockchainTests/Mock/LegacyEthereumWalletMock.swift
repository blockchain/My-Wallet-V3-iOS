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
    
    var checkIfEthereumAccountExistsValue = true
    func checkIfEthereumAccountExists() -> Bool {
        return checkIfEthereumAccountExistsValue
    }
    
    var needsSecondPasswordValue = false
    func needsSecondPassword() -> Bool {
        return needsSecondPasswordValue
    }
    
    static let legacyAccount = LegacyEthereumWalletAccount(
        addr: MockEthereumWalletTestData.account,
        label: "My ETH Wallet"
    )
    static let ethereumAccounts: [[String : Any]] = [[
        "addr": legacyAccount.addr,
        "label": legacyAccount.label
    ]]
    var ethereumAccountsCompletion: NewResult<[[String : Any]], MockLegacyEthereumWalletError> = .success(ethereumAccounts)
    func ethereumAccounts(with secondPassword: String?, success: @escaping ([[String : Any]]) -> Void, error: @escaping (String) -> Void) {
        switch ethereumAccountsCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let labelForAccount: String = "My ETH Wallet"
    var getLabelForEthereumAccountCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success(labelForAccount)
    func getLabelForEthereumAccount(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        switch getLabelForEthereumAccountCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var saveEthereumAccountCompletion: NewResult<Void, MockLegacyEthereumWalletError> = .success(())
    func saveEthereumAccount(with privateKey: String, label: String?, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        switch saveEthereumAccountCompletion {
        case .success:
            success()
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var getEtherAddressCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success("address")
    func getEthereumAddress(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        switch getEtherAddressCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let ethBalanceValue: String = "1337"
    var fetchEthereumBalanceCalled: Bool = false
    var fetchEthereumBalancecCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success(ethBalanceValue)
    func fetchEthereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        switch fetchEthereumBalancecCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var ethereumBalanceCalled: Bool = false
    var ethereumBalancecCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success(ethBalanceValue)
    func ethereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        ethereumBalanceCalled = true
        switch ethereumBalancecCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let ethTransactions: [EtherTransaction] = [
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
    var getEthereumTransactionsCompletion: NewResult<[EtherTransaction], MockLegacyEthereumWalletError> = .success(ethTransactions)
    func getEthereumTransactions(with secondPassword: String?, success: @escaping ([EtherTransaction]) -> Void, error: @escaping (String) -> Void) {
        switch getEthereumTransactionsCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let isWaitingOnEtherTransactionValue: Bool = false
    var isWaitingOnEthereumTransactionCompletion: NewResult<Bool, MockLegacyEthereumWalletError> = .success(isWaitingOnEtherTransactionValue)
    func isWaitingOnEthereumTransaction(with secondPassword: String?, success: @escaping (Bool) -> Void, error: @escaping (String) -> Void) {
        switch isWaitingOnEthereumTransactionCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var lastRecordedEtherTransactionHashAsync: String?
    var recordLastEthereumTransactionCompletion: NewResult<Void, MockLegacyEthereumWalletError> = .success(())
    func recordLastEthereumTransaction(with secondPassword: String?, transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        lastRecordedEtherTransactionHashAsync = transactionHash
        switch recordLastEthereumTransactionCompletion {
        case .success:
            success()
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var getEtherTransactionNonceCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success("1")
    func getEthereumTransactionNonce(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        switch getEtherTransactionNonceCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    static let tokenAccounts: [String: [String: Any]] = [
        "0x8E870D67F660D95d5be530380D0eC0bd388289E1": [
            "label": "My PAX Wallet",
            "contract": "0x8E870D67F660D95d5be530380D0eC0bd388289E1",
            "has_seen": "false",
            "tx_notes": [
                "transaction_hash": "memo"
            ]
        ]
    ]
    var erc20TokensCompletion: NewResult<[String: [String: Any]], MockLegacyEthereumWalletError> = .success(tokenAccounts)
    func erc20Tokens(with secondPassword: String?, success: @escaping ([String : [String : Any]]) -> Void, error: @escaping (String) -> Void) {
        switch erc20TokensCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var lastSavedTokensJSONString: String?
    var saveERC20TokensCompletion: NewResult<Void, MockLegacyEthereumWalletError> = .success(())
    func saveERC20Tokens(with secondPassword: String?, tokensJSONString: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        lastSavedTokensJSONString = tokensJSONString
        switch erc20TokensCompletion {
        case .success:
            success()
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
