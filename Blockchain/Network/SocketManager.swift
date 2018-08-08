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
        case .exchange: self.exchangeSocket = WebSocket(url: url)
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
            socket.advancedDelegate = self
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

        let onSuccess: (String) -> Void = { string in
            socket.write(string: string)
        }

        let onError: () -> Void = {
            Logger.shared.error("Could send websocket message as string")
        }

        message.JSONMessage.tryToEncode(encoding: .utf8, onSuccess: onSuccess, onError: onError)
    }

    private func errorNeedsSocketSetup(socketType: SocketType) -> String {
        return "\(socketType.rawValue) socket needs setup, call setupSocket first"
    }
}

extension SocketManager: WebSocketAdvancedDelegate {
    func websocketDidConnect(socket: WebSocket) {
        if socket == self.exchangeSocket {
            pendingSocketMessages.forEach { [unowned self] in
                self.send(message: $0)
            }
        }
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        let onError: () -> Void = {
            Logger.shared.error("Could not form SocketMessage object from string")
        }

        let onSuccess: (SocketMessage) -> Void = { socketMessage in
            self.webSocketMessageSubject.onNext(socketMessage)
        }

        guard let data = text.data(using: .utf8) else {
            onError()
            return
        }

        // TODO: figure out a way to minimize computation here, such as by decoding to JSON type first and inspecting a certain key-value pair
        Quote.tryToDecode(data: data, onSuccess: onSuccess, onError: onError)
        Rate.tryToDecode(data: data, onSuccess: onSuccess, onError: onError)
        // more structs of type SocketMessageCodable...
    }

    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        // Required by protocol
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
