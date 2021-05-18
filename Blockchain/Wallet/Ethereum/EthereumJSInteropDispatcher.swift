//
//  EthereumJSInteropDispatcher.swift
//  Blockchain
//
//  Created by Jack on 30/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import JavaScriptCore
import ToolKit
import PlatformKit

public enum EthereumJSInteropDispatcherError: Error {
    case jsError(String)
    case unknown
}

@objc public protocol EthereumJSInteropDelegateAPI {
    func didGetAccounts(_ accounts: JSValue)
    func didFailToGetAccounts(errorMessage: JSValue)

    func didGetAddress(_ address: JSValue)
    func didFailToGetAddress(errorMessage: JSValue)
    
    func didGetERC20Tokens(_ tokens: JSValue)
    func didFailToGetERC20Tokens(errorMessage: JSValue)
    
    func didSaveERC20Tokens()
    func didFailToSaveERC20Tokens(errorMessage: JSValue)

    func didRecordLastTransaction()
    func didFailToRecordLastTransaction(errorMessage: JSValue)
}

public protocol EthereumJSInteropDispatcherAPI {
    var getAccounts: Dispatcher<[[String: Any]]> { get }
    var getAddress: Dispatcher<String> { get }
        
    var getERC20Tokens: Dispatcher<[String: [String: Any]]> { get }
    var saveERC20Tokens: Dispatcher<Void> { get }
    
    var recordLastTransaction: Dispatcher<Void> { get }
    var getIsWaitingOnTransaction: Dispatcher<Bool> { get }
}

public class EthereumJSInteropDispatcher: EthereumJSInteropDispatcherAPI {
    static let shared = EthereumJSInteropDispatcher()
    
    public let getAccounts = Dispatcher<[[String: Any]]>()
    
    public let recordLastTransaction = Dispatcher<Void>()
    public let getIsWaitingOnTransaction = Dispatcher<Bool>()
    
    public let getAddress = Dispatcher<String>()
    
    public let getERC20Tokens = Dispatcher<[String: [String: Any]]>()
    public let saveERC20Tokens = Dispatcher<Void>()
}

extension EthereumJSInteropDispatcher: EthereumJSInteropDelegateAPI {
    public func didRecordLastTransaction() {
        recordLastTransaction.sendSuccess(with: ())
    }
    
    public func didFailToRecordLastTransaction(errorMessage: JSValue) {
        sendFailure(dispatcher: recordLastTransaction, errorMessage: errorMessage)
    }
    
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
        Logger.shared.error(message)
        dispatcher.sendFailure(.jsError(message))
    }
}

public final class Dispatcher<Value> {
    public typealias ObserverType = (Result<Value, EthereumJSInteropDispatcherError>) -> Void

    private let lock = NSRecursiveLock()
    private var observers: [ObserverType] = []
    
    public func addObserver(block: @escaping ObserverType) {
        lock.lock(); defer { lock.unlock() }
        observers.append(block)
    }
    
    func sendSuccess(with value: Value) {
        lock.lock(); defer { lock.unlock() }
        guard let observer = observers.first else { return }
        observer(.success(value))
        removeFirstObserver()
    }
    
    func sendFailure(_ error: EthereumJSInteropDispatcherError) {
        lock.lock(); defer { lock.unlock() }
        guard let observer = observers.first else { return }
        observer(.failure(error))
        removeFirstObserver()
    }
    
    private func removeFirstObserver() {
        lock.lock(); defer { lock.unlock() }
        _ = observers.remove(at: 0)
    }
}
