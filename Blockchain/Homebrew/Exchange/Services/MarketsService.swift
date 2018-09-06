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
    var hasAuthenticated: Bool { get }
    var conversions: Observable<Conversion> { get }
    func updateConversion(model: MarketsModel)
}

// MarketsService provides information about crypto/fiat trading data via observables.
// Data can include volume, price, and conversion rates given a quantity, trading pair and
// designated base or counter.
// This class is intended to provide observables for both websockets and REST endpoints.
// Ideally the caller should not care whether websockets or REST is used
// The DataSource enum should default first to websockets, then to REST as fallback.
class MarketsService {
    private let disposables = CompositeDisposable()

    private var socketMessageObservable: Observable<SocketMessage> {
        return SocketManager.shared.webSocketMessageObservable
    }
    private let restMessageSubject = PublishSubject<Conversion>()
    private var dataSource: DataSource = .socket

    private let authentication: NabuAuthenticationService
    var hasAuthenticated: Bool = false

    init(authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared) {
        self.authentication = authenticationService
    }

    deinit {
        disposables.dispose()
    }
}

// MARK: - Setup
extension MarketsService {
    func setup() {
        SocketManager.shared.setupSocket(socketType: .exchange, url: URL(string: BlockchainAPI.shared.retailCoreSocketUrl)!)
    }
}

// MARK: - Data sourcing
private extension MarketsService {
    // Two ways of retrieving data.
    enum DataSource {
        case socket // Using websockets, which is the default dataSource
        case rest // Using REST endpoints, which is the fallback dataSource
    }
}

// MARK: - Public API
extension MarketsService: ExchangeMarketsAPI {
    // MARK: - Authentication
    func authenticate(completion: @escaping () -> Void) {
        switch dataSource {
        case .socket: do {
            subscribeToHeartBeat(completion: completion)
            authenticateSocket()
        }
        case .rest: Logger.shared.debug("use REST endpoint")
        }
    }

    // MARK: - Conversion
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
        switch dataSource {
        case .socket:
            let params = ConversionSubscribeParams(
                type: "pairs",
                pair: model.pair.stringRepresentation,
                fiatCurrency: model.fiatCurrency,
                fix: model.fix,
                volume: model.volume)
            let quote = Subscription(channel: "conversion", operation: "subscribe", params: params)
            let message = SocketMessage(type: .exchange, JSONMessage: quote)
            SocketManager.shared.send(message: message)
        case .rest:
            Logger.shared.debug("Not yet implemented")
        }
    }
}

// MARK: - Private API
private extension MarketsService {
    func subscribeToHeartBeat(completion: @escaping () -> Void) {
        let heartBeatDisposable = socketMessageObservable
            .filter { socketMessage in
                return socketMessage.JSONMessage is HeartBeat
            }
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { [weak self] _ in
                guard let this = self else { return }
                this.hasAuthenticated = true
                completion()
            })

        _ = disposables.insert(heartBeatDisposable)
    }

    func authenticateSocket() {
        let authenticationDisposable = self.authentication.getSessionToken()
            .map { tokenResponse -> Subscription<AuthSubscribeParams> in
                let params = AuthSubscribeParams(type: "auth", token: tokenResponse.token)
                return Subscription(channel: "auth", operation: "subscribe", params: params)
            }.map { message in
                return SocketMessage(type: .exchange, JSONMessage: message)
            }.subscribe(onSuccess: { socketMessage in
                SocketManager.shared.send(message: socketMessage)
            })

        _ = disposables.insert(authenticationDisposable)
    }
}
