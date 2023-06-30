// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import NetworkKit
import WalletConnectRelay

struct SocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        WebSocket(url: url)
    }
}

final class WebSocket: WebSocketConnecting {
    enum WebSocketError: Error {
        case closed
    }

    var isConnected: Bool = false

    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onText: ((String) -> Void)?
    var request: URLRequest {
        didSet {
            if let url = request.url {
                self.connection = createConnection(url: url)
                self.url = url
                self.isConnected = false
            }
        }
    }

    private var connection: WebSocketConnection?
    private var url: URL

    init(url: URL) {
        self.url = url
        self.request = URLRequest(url: url)
        self.connection = createConnection(url: url)
    }

    private func createConnection(url: URL) -> WebSocketConnection {
        let handler: (WebSocketConnection.Event) -> Void = { [weak self] event in
            guard let self else { return }
            switch event {
            case .connected:
                isConnected = true
                onConnect?()
            case .disconnected(.error(let error)):
                isConnected = false
                onDisconnect?(error)
            case .disconnected(.closeCode):
                isConnected = false
                onDisconnect?(WebSocketError.closed)
            case .received(.string(let value)):
                onText?(value)
            case .received(.data(let data)):
                guard let value = String(data: data, encoding: .utf8) else {
                    return
                }
                onText?(value)
            }
        }
        return WebSocketConnection(
            url: url,
            handler: handler,
            consoleLogger: nil,
            networkDebugLogger: nil,
            sendsPing: false
        )
    }

    func connect() {
        connection?.open()
    }

    func disconnect() {
        connection?.close(closeCode: .normalClosure)
    }

    func write(string: String, completion: (() -> Void)?) {
        connection?.send(.string(string), onCompletion: completion)
    }
}
