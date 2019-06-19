//
//  Wallet+LegacyEthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 29/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol LegacyEthereumWalletProtocol: class {
    var password: String? { get }

    func checkIfEthereumAccountExists() -> Bool
    
    func needsSecondPassword() -> Bool
    
    func ethereumAccounts(with secondPassword: String?, success: @escaping ([[String: Any]]) -> Void, error: @escaping (String) -> Void)
    func getLabelForEthereumAccount(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    func saveEthereumAccount(with privateKey: String, label: String?, success: @escaping () -> Void, error: @escaping (String) -> Void)
    func getEthereumAddress(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    
    func fetchEthereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    func ethereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    func getEthereumTransactions(with secondPassword: String?, success: @escaping ([EtherTransaction]) -> Void, error: @escaping (String) -> Void)
    
    func isWaitingOnEthereumTransaction(with secondPassword: String?, success: @escaping (Bool) -> Void, error: @escaping (String) -> Void)
    func recordLastEthereumTransaction(with secondPassword: String?, transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void)
    func getEthereumTransactionNonce(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    
    func erc20Tokens(with secondPassword: String?, success: @escaping ([String: [String: Any]]) -> Void, error: @escaping (String) -> Void)
    func saveERC20Tokens(with secondPassword: String?, tokensJSONString: String, success: @escaping () -> Void, error: @escaping (String) -> Void)
}

extension Wallet: LegacyEthereumWalletProtocol {
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
    
    public func saveEthereumAccount(with privateKey: String, label: String?, success: @escaping () -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.saveAccount.addObserver { result in
            switch result {
            case .success:
                success()
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let escapedPrivateKey = privateKey.escapedForJS()
        let function: String = "MyWalletPhone.saveEtherAccountAsync"
        let script: String
        if let escapedLabel = label?.escapedForJS() {
            script = "\(function)(\(escapedPrivateKey), \(escapedLabel))"
        } else {
            script = "\(function)(\(escapedPrivateKey)))"
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
    
    public func fetchEthereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.fetchBalance.addObserver { result in
            switch result {
            case .success(let balance):
                success(balance)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getAvailableEthBalanceAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    public func ethereumBalance(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        success(self.getEthBalanceTruncated())
    }
    
    public func getEthereumTransactions(with secondPassword: String?, success: @escaping ([EtherTransaction]) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.getTransactions.addObserver { result in
            switch result {
            case .success(let transactions):
                success(transactions)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getEthTransactionsAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    public func isWaitingOnEthereumTransaction(with secondPassword: String?, success: @escaping (Bool) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.getIsWaitingOnTransaction.addObserver { result in
            switch result {
            case .success(let isWaiting):
                success(isWaiting)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.isWaitingOnTransactionAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    public func recordLastEthereumTransaction(with secondPassword: String?, transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void) {
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
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedTransactionHash), \(escapedSecondPassword))"
        } else {
            script = "\(function)(\(escapedTransactionHash))"
        }
        context.evaluateScript(script)
    }
    
    public func getEthereumTransactionNonce(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        ethereum.interopDispatcher.getNonce.addObserver { result in
            switch result {
            case .success(let nonce):
                success(nonce)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getEtherTransactionNonceAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
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
}
