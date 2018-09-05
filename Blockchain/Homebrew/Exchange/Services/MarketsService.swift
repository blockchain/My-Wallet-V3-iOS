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
    func update(newPair: TradingPair)
}

class MarketsService {
    // Two ways of retrieving data.
    private enum DataSource {
        case socket // Using websockets, which is the default dataSource
        case rest // Using REST endpoints, which is the fallback dataSource
    }
    private var dataSource: DataSource = .socket

    private var pair: TradingPair? {
        didSet {
            SocketManager.shared.setupSocket(socketType: .exchange, url: URL(string: BlockchainAPI.Nabu.quotes)!)
            SocketManager.shared.connect(socketType: .exchange)
            authenticate()
        }
    }
    func update(newPair: TradingPair) {
        pair = newPair
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

    func authenticate() {
        switch dataSource {
        case .socket: do {
            let params = AuthParams(type: "auth", token: "jwtToken")
            let message = Auth(channel: "auth", operation: "subscribe", params: params)
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

extension MarketsService {
    func onChangeAmountFieldText() {
        // TODO
        //        switch dataSource {
        //        case .socket: // calculate
        //        case .rest: // send request, show spinner?
        //        }
    }
}

extension MarketsService: ExchangeMarketsAPI {
    
}
