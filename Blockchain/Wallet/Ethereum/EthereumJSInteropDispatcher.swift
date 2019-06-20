//
//  EthereumJSInteropDispatcher.swift
//  Blockchain
//
//  Created by Jack on 30/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum EthereumJSInteropDispatcherError: Error {
    case jsError(String)
    case unknown
}

@objc public protocol EthereumJSInteropDelegateAPI {
    func didGetAccounts(_ accounts: JSValue)
    func didFailToGetAccounts(errorMessage: JSValue)
    
    func didSaveAccount()
    func didFailToSaveAccount(errorMessage: JSValue)

    func didFetchBalance(_ balance: JSValue)
    func didFailToFetchBalance(errorMessage: JSValue)

    func didGetBalance(_ balance: JSValue)
    func didFailToGetBalance(errorMessage: JSValue)
    
    func didGetAddress(_ address: JSValue)
    func didFailToGetAddress(errorMessage: JSValue)
    
    func didFetchHistory()
    func didFailToFetchHistory(errorMessage: JSValue)
    
    func didGetTransactions(_ transactions: JSValue)
    func didFailToGetTransactions(errorMessage: JSValue)

    func didRecordLastTransaction()
    func didFailToRecordLastTransaction(errorMessage: JSValue)

    func didGetIsWaitingOnTransaction(_ isWaitingOnTransaction: JSValue)
    func didFailToGetIsWaitingOnTransaction(errorMessage: JSValue)

    func didGetNonce(_ nonce: JSValue)
    func didFailToGetNonce(errorMessage: JSValue)
    
    func didGetERC20Tokens(_ tokens: JSValue)
    func didFailToGetERC20Tokens(errorMessage: JSValue)
    
    func didSaveERC20Tokens()
    func didFailToSaveERC20Tokens(errorMessage: JSValue)
}

protocol EthereumJSInteropDispatcherAPI {
    var getAccounts: Dispatcher<[[String: Any]]> { get }
    var saveAccount: Dispatcher<Void> { get }
    
    var fetchHistory: Dispatcher<Void> { get }
    var getTransactions: Dispatcher<[EtherTransaction]> { get }
    var fetchBalance: Dispatcher<String> { get }
    var getBalance: Dispatcher<String> { get }
    var getAddress: Dispatcher<String> { get }
    
    var recordLastTransaction: Dispatcher<Void> { get }
    var getIsWaitingOnTransaction: Dispatcher<Bool> { get }
    var getNonce: Dispatcher<String> { get }
    
    var getERC20Tokens: Dispatcher<[String: [String: Any]]> { get }
    var saveERC20Tokens: Dispatcher<Void> { get }
}

public class EthereumJSInteropDispatcher: EthereumJSInteropDispatcherAPI {
    static let shared = EthereumJSInteropDispatcher()
    
    let getAccounts = Dispatcher<[[String: Any]]>()
    let saveAccount = Dispatcher<Void>()
    
    let fetchHistory = Dispatcher<Void>()
    let getTransactions = Dispatcher<[EtherTransaction]>()
    let fetchBalance = Dispatcher<String>()
    let getBalance = Dispatcher<String>()
    let getAddress = Dispatcher<String>()
    
    let recordLastTransaction = Dispatcher<Void>()
    let getIsWaitingOnTransaction = Dispatcher<Bool>()
    let getNonce = Dispatcher<String>()
    
    let getERC20Tokens = Dispatcher<[String: [String: Any]]>()
    let saveERC20Tokens = Dispatcher<Void>()
}

extension EthereumJSInteropDispatcher: EthereumJSInteropDelegateAPI {
    public func didGetAccounts(_ accounts: JSValue) {
        guard let accountsDictionaries = accounts.toArray() as? [[String: Any]] else {
            getAccounts.sendFailure(.unknown)
            return
        }
        getAccounts.sendSuccess(with: accountsDictionaries)
    }
    
    public func didFailToGetAccounts(errorMessage: JSValue) {
        sendFailure(dispatcher: getAccounts, errorMessage: errorMessage)
    }
    
    public func didSaveAccount() {
        saveAccount.sendSuccess(with: ())
    }
    
    public func didFailToSaveAccount(errorMessage: JSValue) {
        sendFailure(dispatcher: saveAccount, errorMessage: errorMessage)
    }
    
    public func didFetchBalance(_ balance: JSValue) {
        guard let balance = balance.toString() else {
            fetchBalance.sendFailure(.unknown)
            return
        }
        fetchBalance.sendSuccess(with: balance)
    }
    
    public func didFailToFetchBalance(errorMessage: JSValue) {
        sendFailure(dispatcher: fetchBalance, errorMessage: errorMessage)
    }
    
    public func didGetBalance(_ balance: JSValue) {
        guard let balance = balance.toString() else {
            getBalance.sendFailure(.unknown)
            return
        }
        getBalance.sendSuccess(with: balance)
    }
    
    public func didFailToGetBalance(errorMessage: JSValue) {
        sendFailure(dispatcher: getBalance, errorMessage: errorMessage)
    }
    
    public func didGetAddress(_ address: JSValue) {
        guard let address = address.toString() else {
            getAddress.sendFailure(.unknown)
            return
        }
        getAddress.sendSuccess(with: address)
    }
    
    public func didFailToGetAddress(errorMessage: JSValue) {
        sendFailure(dispatcher: getAddress, errorMessage: errorMessage)
    }
    
    public func didFetchHistory() {
        fetchHistory.sendSuccess(with: ())
    }
    
    public func didFailToFetchHistory(errorMessage: JSValue) {
        sendFailure(dispatcher: fetchHistory, errorMessage: errorMessage)
    }
    
    public func didGetTransactions(_ transactions: JSValue) {
        guard let transactionsDictionaries = transactions.toArray() as? [[String: Any]] else {
            getTransactions.sendFailure(.unknown)
            return
        }
        let convertedTransactions = transactionsDictionaries.compactMap { dict in
            return EtherTransaction.fromJSONDict(dict)
        }
        getTransactions.sendSuccess(with: convertedTransactions)
    }
    
    public func didFailToGetTransactions(errorMessage: JSValue) {
        sendFailure(dispatcher: getTransactions, errorMessage: errorMessage)
    }
    
    public func didRecordLastTransaction() {
        recordLastTransaction.sendSuccess(with: ())
    }
    
    public func didFailToRecordLastTransaction(errorMessage: JSValue) {
        sendFailure(dispatcher: recordLastTransaction, errorMessage: errorMessage)
    }
    
    public func didGetIsWaitingOnTransaction(_ isWaitingOnTransaction: JSValue) {
        getIsWaitingOnTransaction.sendSuccess(with: isWaitingOnTransaction.toBool())
    }
    
    public func didFailToGetIsWaitingOnTransaction(errorMessage: JSValue) {
        sendFailure(dispatcher: getIsWaitingOnTransaction, errorMessage: errorMessage)
    }
    
    public func didGetNonce(_ nonce: JSValue) {
        guard let nonce = nonce.toString() else {
            getNonce.sendFailure(.unknown)
            return
        }
        getNonce.sendSuccess(with: nonce)
    }
    
    public func didFailToGetNonce(errorMessage: JSValue) {
        sendFailure(dispatcher: getNonce, errorMessage: errorMessage)
    }
    
    public func didGetERC20Tokens(_ tokens: JSValue) {
        guard let tokensDictionaries = tokens.toDictionary() as? [String: [String: Any]] else {
            getERC20Tokens.sendFailure(.unknown)
            return
        }
        getERC20Tokens.sendSuccess(with: tokensDictionaries)
    }
    
    public func didFailToGetERC20Tokens(errorMessage: JSValue) {
        sendFailure(dispatcher: getERC20Tokens, errorMessage: errorMessage)
    }
    
    public func didSaveERC20Tokens() {
        saveERC20Tokens.sendSuccess(with: ())
    }
    
    public func didFailToSaveERC20Tokens(errorMessage: JSValue) {
        sendFailure(dispatcher: saveERC20Tokens, errorMessage: errorMessage)
    }
    
    private func sendFailure<T>(dispatcher: Dispatcher<T>, errorMessage: JSValue) {
        guard let message = errorMessage.toString() else {
            dispatcher.sendFailure(.unknown)
            return
        }
        dispatcher.sendFailure(.jsError(message))
    }
}

final class Dispatcher<Value> {
    typealias ObserverType = (NewResult<Value, EthereumJSInteropDispatcherError>) -> Void
    
    private var observers: [ObserverType] = []
    
    func addObserver(block: @escaping ObserverType) {
        observers.append(block)
    }
    
    func sendSuccess(with value: Value) {
        guard let observer = observers.first else { return }
        observer(.success(value))
        removeFirstObserver()
    }
    
    func sendFailure(_ error: EthereumJSInteropDispatcherError) {
        guard let observer = observers.first else { return }
        observer(.failure(error))
        removeFirstObserver()
    }
    
    private func removeFirstObserver() {
        _ = observers.remove(at: 0)
    }
}
