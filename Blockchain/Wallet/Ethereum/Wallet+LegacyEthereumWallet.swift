//
//  Wallet+LegacyEthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 29/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

extension Wallet: LegacyEthereumWalletAPI {
    public func getEthereumMemo(for transaction: String, success: @escaping (String?) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        let function: String = "MyWalletPhone.getEtherNote(\"\(transaction.escapedForJS())\")"
        guard
            let result: String = context.evaluateScript(function)?.toString(),
            !result.isEmpty,
            result != "null"
            else {
                success(nil)
                return
        }
        success(result)
    }

    public func setEthereumMemo(for transaction: String, memo: String?) {
        guard isInitialized() else {
            return
        }
        let memo: String = memo?.escapedForJS() ?? ""
        let transaction = transaction.escapedForJS()
        let function: String = "MyWalletPhone.saveEtherNote(\"\(transaction)\", \"\(memo)\")"
        context.evaluateScript(function)
    }

    public func ethereumAccounts(with secondPassword: String?, success: @escaping ([[String: Any]]) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.getAccounts.addObserver { result in
            switch result {
            case .success(let accounts):
                success(accounts)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getEtherAccountsAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }

    public func getLabelForEthereumAccount(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        self.ethereumAccounts(with: secondPassword, success: { accounts in
            guard
                let ethereumAccountsDicts = accounts as? [[String:Any]],
                let defaultAccount = ethereumAccountsDicts.first,
                let label = defaultAccount["label"] as? String
            else {
                error("No ethereum accounts.")
                return
            }
            success(label)
        }, error: { errorMessage in
            error(errorMessage)
        })
    }
    
    public func getEthereumAddress(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        self.ethereumAccounts(with: secondPassword, success: { accounts in
            guard
                let ethereumAccountsDicts = accounts as? [[String:Any]],
                let defaultAccount = ethereumAccountsDicts.first,
                let addr = defaultAccount["addr"] as? String
            else {
                error("No ethereum accounts.")
                return
            }
            success(addr)
        }, error: { errorMessage in
            error(errorMessage)
        })
    }
    
    public func erc20Tokens(with secondPassword: String?, success: @escaping ([String: [String: Any]]) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.getERC20Tokens.addObserver { result in
            switch result {
            case .success(let tokens):
                success(tokens)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getERC20TokensAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    public func saveERC20Tokens(with secondPassword: String?, tokensJSONString: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.saveERC20Tokens.addObserver { result in
            switch result {
            case .success:
                success()
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.setERC20TokensAsync"
        let escapedTokens = tokensJSONString
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\'\(escapedTokens)\', \(escapedSecondPassword))"
        } else {
            script = "\(function)(\'\(escapedTokens)\')"
        }
        context.evaluateScript(script)
    }
    
    @objc public func checkIfEthereumAccountExists() -> Bool {
        guard isInitialized() else { return false }
        return context.evaluateScript("MyWalletPhone.ethereumAccountExists()").toBool()
    }

    public func recordLastEthereumTransaction(transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.recordLastTransaction.addObserver { result in
            switch result {
            case .success:
                success()
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let escapedTransactionHash = "'\(transactionHash.escapedForJS())'"
        let function: String = "MyWalletPhone.recordLastTransactionAsync"
        let script = "\(function)(\(escapedTransactionHash))"
        context.evaluateScript(script)
    }
}
