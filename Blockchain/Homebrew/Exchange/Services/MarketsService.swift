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
    func authenticate(completion: @escaping (SocketMessage) -> Void)
    var pair: TradingPair? { get set }
    func fetchRates()
    var rates: Observable<ExchangeRate> { get }
}

class MarketsService: ExchangeMarketsAPI {
    private let authentication: KYCAuthenticationService
    private var disposable: Disposable?

    init(service: KYCAuthenticationService = KYCAuthenticationService.shared) {
        self.authentication = service
    }

    deinit {
        disposable?.dispose()
        disposable = nil
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

    func authenticate(completion: @escaping (SocketMessage) -> Void) {
        switch dataSource {
        case .socket: do {
            SocketManager.shared.setupSocket(socketType: .exchange, url: URL(string: BlockchainAPI.Nabu.quotes)!)
            disposable = authentication.getKycSessionToken().flatMap { [unowned self] token in
                let params = AuthParams(type: "auth", token: token.token)
                let message = Auth(channel: "auth", operation: "subscribe", params: params)
                do {
                    let encoded = try message.encodeToString(encoding: .utf8)
                    let socketMessage = SocketMessage(type: .exchange, JSONMessage: encoded)
                    SocketManager.shared.send(message: socketMessage)
                } catch {
                    Logger.shared.error("Could not encode socket message")
                }
                return self.socketMessageObservable.asSingle()
            }.subscribe(onSuccess: { message in
                completion(message)
            }) { error in
                Logger.shared.error("Could not authenticate")
            }
        }
        case .rest: Logger.shared.debug("use REST endpoint")
        }
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
