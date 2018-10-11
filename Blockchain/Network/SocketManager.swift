//
//  SocketManager.swift
//  Blockchain
//
//  Created by kevinwu on 8/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Starscream
import RxSwift

class SocketManager {
    static let shared = SocketManager()

    private var exchangeSocket: WebSocket?
    // Add the following properties when removing the websocket from Wallet class
    // private let btcSocket: Websocket
    // private let ethSocket: Websocket
    // private let bchSocket: Websocket

    // MARK: - Initialization
    init() {
        self.webSocketMessageSubject = PublishSubject<SocketMessage>()
    }

    /// Data providers should suscribe to this and filter (e.g., { $0 is ExchangeSocketMessage })
    var webSocketMessageObservable: Observable<SocketMessage> {
        return webSocketMessageSubject.asObservable()
    }
    private let webSocketMessageSubject: PublishSubject<SocketMessage>
    private var pendingSocketMessages = [SocketMessage]()
    private let errorUnsupportedSocketType = "Unsupported socket type"

    // MARK: - Public methods
    func setupSocket(socketType: SocketType, url: URL) {
        switch socketType {
        case .exchange: self.exchangeSocket = WebSocket(url: url); self.exchangeSocket?.advancedDelegate = self
        default: Logger.shared.error(errorUnsupportedSocketType)
        }
    }

    func send(message: SocketMessage) {
        switch message.type {
        case .exchange:
            guard let socket = exchangeSocket else {
                Logger.shared.error(errorNeedsSocketSetup(socketType: message.type))
                return
            }
            tryToSend(message: message, socket: socket)
        default: Logger.shared.error(errorUnsupportedSocketType)
        }
    }

    func connect(socketType: SocketType) {
        switch socketType {
        case .exchange:
            guard let socket = exchangeSocket else {
                Logger.shared.error(errorNeedsSocketSetup(socketType: socketType))
                return
            }
            socket.connect()
        default: Logger.shared.error(errorUnsupportedSocketType)
        }
    }

    func disconnect(socketType: SocketType) {
        switch socketType {
        case .exchange:
            guard let socket = exchangeSocket else {
                Logger.shared.error(errorNeedsSocketSetup(socketType: socketType))
                return
            }
            socket.disconnect()
        default: Logger.shared.error(errorUnsupportedSocketType)
        }
    }

    // MARK: - Private methods
    private func tryToSend(message: SocketMessage, socket: WebSocket) {
        guard socket.isConnected else {
            Logger.shared.info("Exchange socket is not connected - will append message to pending messages")
            pendingSocketMessages.append(message)
            socket.connect()
            return
        }

        do {
            let string = try message.JSONMessage.encodeToString(encoding: .utf8)
            Logger.shared.debug("Writing to socket: \(string)")
            socket.write(string: string)
        } catch {
            Logger.shared.error("Could not send websocket message as string")
        }
    }

    private func errorNeedsSocketSetup(socketType: SocketType) -> String {
        return "\(socketType.rawValue) socket needs setup, call setupSocket first"
    }
}

extension SocketManager: WebSocketAdvancedDelegate {
    func websocketDidConnect(socket: WebSocket) {
        Logger.shared.debug("Websocket connected to: \(socket.currentURL.absoluteString)")
        if socket == self.exchangeSocket {
            pendingSocketMessages.forEach { [unowned self] in
                self.send(message: $0)
            }
        }
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        let socketType: SocketType = socket == self.exchangeSocket ? .exchange : .unassigned

        let onAcknowledge: (String) -> Void = { message in
            Logger.shared.debug("Acknowledged messsage: \(message)")
        }

        let onError: (String) -> Void = { message in
            Logger.shared.error("Could not form SocketMessage object from string: \(message)")
        }

        let onSuccess: (SocketMessage) -> Void = { socketMessage in
            self.webSocketMessageSubject.onNext(socketMessage)
        }

        guard let data = text.data(using: .utf8) else {
            onError("Couldn't form data from string")
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as! [String: AnyObject] else {
            onError("Couldn't create JSON object from data")
            return
        }

        guard let channel = json["channel"] as? String else {
            onError("Channel is not a string value")
            return
        }

        // Optimization: avoid retyping "tryToDecode(data: data, onSuccess: onSuccess, onError: onError)" for each case
        switch channel {
        case "auth":
            onAcknowledge("Successfully unsubscribed. Payload: \(text)")
        case "exchange_rate":
            Logger.shared.debug("Attempting to decode: \(text)")
            ExchangeRates.tryToDecode(socketType: socketType, data: data, onSuccess: onSuccess, onError: onError)
        case "conversion":
            if let event = json["event"] as? String, event == "updated" {
                guard let type = json["type"] as? String else {
                    Logger.shared.error("Incorrect type or type key not found: \(text)")
                    return
                }

                switch type {
                case "currencyRatio":
                    Conversion.tryToDecode(socketType: socketType, data: data, onSuccess: onSuccess, onError: onError)
                case "currencyRatioError":
                    /// Though this is an error, we still decode the payload
                    /// as a `SocketMessage`, so it will use the `onSuccess`
                    /// closure and not the `onError`.
                    SocketError.tryToDecode(socketType: socketType, data: data, onSuccess: onSuccess, onError: onError)
                default:
                    Logger.shared.error("Unsupported conversion type: \(text)")
                }
            }
        case "heartbeat", "subscribed", "authenticated":
            HeartBeat.tryToDecode(socketType: socketType, data: data, onSuccess: onSuccess, onError: onError)
        case "error":
            onError("Error returned: \(json)")
            SocketError.tryToDecode(socketType: socketType, data: data, onSuccess: onSuccess, onError: onError)
        default:
            onError("Unsupported channel: '\(channel)'")
        }
    }

    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        // Required by protocol
        Logger.shared.debug("Websocket disconnected from: \(socket.currentURL.absoluteString)")
    }

    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
        // Required by protocol
    }

    func websocketHttpUpgrade(socket: WebSocket, request: String) {
        // Required by protocol
    }

    func websocketHttpUpgrade(socket: WebSocket, response: String) {
        // Required by protocol
    }
}
