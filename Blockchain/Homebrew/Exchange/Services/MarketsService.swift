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
    func fetchRates()
    var conversions: Observable<Conversion> { get }
    func updateConversion(model: MarketsModel)
    var hasAuthenticated: Bool { get }
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

    private var socketMessageObservable: Observable<SocketMessage> {
        return SocketManager.shared.webSocketMessageObservable
    }
    private let restMessageSubject = PublishSubject<Conversion>()

    var conversions: Observable<Conversion> {
        switch dataSource {
        case .socket:
            return socketMessageObservable.filter {
                $0.type == .exchange &&
                $0.JSONMessage is Conversion
            }.map { message in
                return message.JSONMessage as! Conversion
            }
        case .rest:
            return restMessageSubject.filter({ _ -> Bool in
                return false
            })
        }
    }
    func updateConversion(model: MarketsModel) {
        guard let pair = model.pair, let fiatCurrency = model.fiatCurrency else {
            Logger.shared.error("Missing pair or fiat currency")
            return
        }
        let params = ConversionSubscribeParams(
            type: "pairs",
            pair: pair.stringRepresentation,
            fiatCurrency: fiatCurrency,
            fix: model.fix,
            volume: model.volume)
        let quote = Subscription(channel: "conversion", operation: "subscribe", params: params)
        let message = SocketMessage(type: .exchange, JSONMessage: quote)
        SocketManager.shared.send(message: message)
    }

    func setup() {
        setupSocket()
    }

    private func setupSocket() {
        SocketManager.shared.setupSocket(socketType: .exchange, url: URL(string: BlockchainAPI.shared.retailCoreSocketUrl)!)
    }

    var hasAuthenticated: Bool = false
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
                return socketMessage.JSONMessage is HeartBeat
            }
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { [unowned self] _ in
                self.hasAuthenticated = true
                completion()
            })

        _ = disposables?.insert(heartBeatDisposable)
    }

    private func authenticateSocket() {
        let authenticationDisposable = KYCAuthenticationService.shared.getKycSessionToken()
            .map { tokenResponse -> Subscription<AuthSubscribeParams> in
                let params = AuthSubscribeParams(type: "auth", token: tokenResponse.token)
                return Subscription(channel: "auth", operation: "subscribe", params: params)
            }.map { message in
                return SocketMessage(type: .exchange, JSONMessage: message)
            }.map { socketMessage in
                SocketManager.shared.send(message: socketMessage)
            }.subscribe()

        _ = disposables?.insert(authenticationDisposable)
    }

    func fetchRates() {
        switch dataSource {
        case .socket: do {
            let message = Rate(parameterOne: "rate")
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
