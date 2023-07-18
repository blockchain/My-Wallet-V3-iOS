// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import NetworkKit
import SwiftExtensions
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

    private let lock = UnfairLock()

    private var _request: URLRequest
    private var _isConnected: Bool = false

    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onText: ((String) -> Void)?

    var isConnected: Bool {
        get { lock.withLock { _isConnected } }
        set { lock.withLock { _isConnected = newValue } }
    }

    var request: URLRequest {
        get { lock.withLock { _request } }
        set {
            lock.withLock {
                _request = newValue
                if let url = _request.url {
                    connection = createConnection(url: url)
                }
            }
        }
    }

    private var connection: WebSocketConnection?

    init(url: URL) {
        self._request = URLRequest(url: url)
        self.connection = createConnection(url: url)
    }

    private func createConnection(url: URL) -> WebSocketConnection {
        let handler: (WebSocketConnection.Event) -> Void = { [weak self] event in
            guard let self else { return }
            DispatchQueue.main.async {
                switch event {
                case .connected:
                    self.isConnected = true
                    self.onConnect?()
                case .disconnected(.error(let error)):
                    self.isConnected = false
                    self.onDisconnect?(error)
                case .disconnected(.closeCode):
                    self.isConnected = false
                    self.onDisconnect?(WebSocketError.closed)
                case .received(.string(let value)):
                    self.onText?(value)
                case .received(.data(let data)):
                    guard let value = String(data: data, encoding: .utf8) else {
                        return
                    }
                    self.onText?(value)
                }
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
        lock.lock(); defer { lock.unlock() }
        connection?.open()
    }

    func disconnect() {
        lock.lock(); defer { lock.unlock() }
        connection?.close(closeCode: .normalClosure)
    }

    func write(string: String, completion: (() -> Void)?) {
        lock.lock(); defer { lock.unlock() }
        connection?.send(.string(string), onCompletion: completion)
    }
}
