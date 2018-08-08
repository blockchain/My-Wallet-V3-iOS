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

    private let exchangeSocket: WebSocket
    // Add the following properties when removing the websocket from Wallet class
    // private let btcSocket: Websocket
    // private let ethSocket: Websocket
    // private let bchSocket: Websocket

    // MARK: - Initialization
    init() {
        self.exchangeSocket = WebSocket(url: URL(string: BlockchainAPI.Nabu.quotes)!)
        self.webSocketMessageSubject = PublishSubject<SocketMessage>()
    }

    /// Data providers should suscribe to this and filter (e.g., { $0 is ExchangeSocketMessage })
    var webSocketMessageObservable: Observable<SocketMessage> {
        return webSocketMessageSubject.asObservable()
    }

    private let webSocketMessageSubject: PublishSubject<SocketMessage>
    private lazy var pendingSocketMessages = [SocketMessage]()

    // MARK: - Public methods
    func send(message: SocketMessage) {
        switch message.type {
        case .exchange: tryToSend(message: message, socket: exchangeSocket)
        default: Logger.shared.error("Send message: unsupported socket message type")
        }
    }

    private func tryToSend(message: SocketMessage, socket: WebSocket) {
        guard socket.isConnected else {
            Logger.shared.info("Exchange socket is not connected - will append message to pending messages")
            pendingSocketMessages.append(message)
            socket.connect()
            return
        }

        let onError: () -> Void = {
            Logger.shared.error("Could send websocket message as string")
        }

        do {
            let encodedData = try message.JSONMessage.encode()
            guard let string = String(data: encodedData, encoding: .utf8) else {
                onError()
                return
            }
            socket.write(string: string)
        } catch {
            onError()
        }
    }

    func connect(socketType: SocketMessageType) {
        switch socketType {
        case .exchange:
            self.exchangeSocket.advancedDelegate = self
            self.exchangeSocket.connect()
        default: Logger.shared.error("Connect socketType: unsupported socket type")
        }
    }

    func disconnect(socketType: SocketMessageType) {
        switch socketType {
        case .exchange: exchangeSocket.disconnect()
        default: Logger.shared.error("Disconnect socketType: unsupported socket type")
        }
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
