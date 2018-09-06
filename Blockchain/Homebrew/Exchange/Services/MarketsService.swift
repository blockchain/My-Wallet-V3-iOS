//
//  MarketsService.swift
//  Blockchain
//
//  Created by kevinwu on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol ExchangeMarketsAPI {
    func setup()
    func authenticate(completion: @escaping () -> Void)
    var pair: TradingPair? { get set }
    func fetchRates()
    var rates: Observable<ExchangeRate> { get }
}

class MarketsService: ExchangeMarketsAPI {
    private let authentication: KYCAuthenticationService
    private var disposables: CompositeDisposable?

    init(service: KYCAuthenticationService = KYCAuthenticationService.shared) {
        self.authentication = service
    }

    deinit {
        disposables?.dispose()
    }

    // Two ways of retrieving data.
    private enum DataSource {
        case socket // Using websockets, which is the default dataSource
        case rest // Using REST endpoints, which is the fallback dataSource
    }
    private var dataSource: DataSource = .socket

    var pair: TradingPair? {
        didSet {
            let quote = Quote(parameterOne: "param")
            let message = SocketMessage(type: .exchange, JSONMessage: quote)
            SocketManager.shared.send(message: message)
        }
    }

    private var socketMessageObservable: Observable<SocketMessage> {
        return SocketManager.shared.webSocketMessageObservable
    }
    private let restMessageSubject = PublishSubject<ExchangeRate>()

    var rates: Observable<ExchangeRate> {
        switch dataSource {
        case .socket:
            return socketMessageObservable.filter {
                $0.type == .exchange &&
                $0.JSONMessage is Quote
            }.map { message in
                // return message.JSONMessage as! Quote
                return ExchangeRate(javaScriptValue: JSValue())!
            }
        case .rest:
            return restMessageSubject.filter({ _ -> Bool in
                return false
            })
        }
    }

    func setup() {
        setupSocket()
    }

    private func setupSocket() {
        SocketManager.shared.setupSocket(socketType: .exchange, url: URL(string: BlockchainAPI.shared.retailCoreSocketUrl)!)
    }

    func authenticate(completion: @escaping () -> Void) {
        switch dataSource {
        case .socket: do {
            subscribeToHeartBeat(completion: completion)
            authenticateSocket()
        }
        case .rest: Logger.shared.debug("use REST endpoint")
        }
    }

    private func subscribeToHeartBeat(completion: @escaping () -> Void) {
        let heartBeatDisposable = socketMessageObservable
            .filter { socketMessage in
                // make sure it's a heartbeat
                return true
            }
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { _ in
                completion()
            })

        _ = disposables?.insert(heartBeatDisposable)
    }

    private func authenticateSocket() {
        let authenticationDisposable = KYCAuthenticationService.shared.getKycSessionToken().map { tokenResponse -> Auth in
            let params = AuthParams(type: "auth", token: tokenResponse.token)
            return Auth(channel: "auth", operation: "subscribe", params: params)
            }.map { message in
                return try message.encodeToString(encoding: .utf8)
            }.map { encoded in
                return SocketMessage(type: .exchange, JSONMessage: encoded)
            }.map { socketMessage in
                SocketManager.shared.send(message: socketMessage)
            }.subscribe()

        _ = disposables?.insert(authenticationDisposable)
    }

    func fetchRates() {
        switch dataSource {
        case .socket: do {
            let message = Quote(parameterOne: "parameterOne")
            do {
                let encoded = try message.encodeToString(encoding: .utf8)
                let socketMessage = SocketMessage(type: .exchange, JSONMessage: encoded)
                SocketManager.shared.send(message: socketMessage)
            } catch {
                Logger.shared.error("Could not encode socket message")
            }
        }
        case .rest: Logger.shared.debug("use REST endpoint")
        }
    }
}
