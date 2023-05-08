// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import NetworkKit
import WalletConnectRelay

struct SocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        WebSocket(
            url: url,
            connection: .init(
                url: url,
                handler: nil,
                consoleLogger: nil,
                networkDebugLogger: DIKit.resolve(),
                sendsPing: false
            )
        )
    }
}

final class WebSocket: WebSocketConnecting {
    enum WebSocketError: Error {
        case closed
    }

    var isConnected: Bool {
        connection.isConnected
    }

    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onText: ((String) -> Void)?
    var request: URLRequest

    private let connection: WebSocketConnection
    private let url: URL

    init(url: URL, connection: WebSocketConnection) {
        self.url = url
        self.request = URLRequest(url: url, timeoutInterval: 30)
        self.connection = connection

        connection.handler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .connected:
                onConnect?()
            case .disconnected(.error(let error)):
                onDisconnect?(error)
            case .disconnected(.closeCode):
                onDisconnect?(WebSocketError.closed)
            case .received(.string(let value)):
                onText?(value)
            case .received(.data(let data)):
                guard let value = String(data: data, encoding: .utf8) else {
                    return
                }
                onText?(value)
            case .recoverFromURLSessionCompletionError:
                return
            }
        }
    }

    func connect() {
        // WalletConnect can alter the URL after a disconnection when an error occurs - use the request variable directly
        connection.open { [request] _ in
            request
        }
    }

    func disconnect() {
        connection.close(closeCode: .normalClosure)
    }

    func write(string: String, completion: (() -> Void)?) {
        connection.send(.string(string), onCompletion: completion)
    }
}
