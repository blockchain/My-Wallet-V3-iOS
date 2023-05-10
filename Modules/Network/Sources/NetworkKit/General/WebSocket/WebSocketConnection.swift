// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import Network

public final class WebSocketConnection {
    public enum Event: Equatable {
        case connected
        case disconnected(DisconnectionData)
        case received(Message)
        case recoverFromURLSessionCompletionError
    }

    private let url: URL
    public var handler: ((Event) -> Void)?

    private(set) public var isConnected: Bool = false
    private var task: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    private var loggerURLRequest: URLRequest?
    private let consoleLogger: ((String) -> Void)?
    private let networkDebugLogger: NetworkDebugLogger
    private let sendsPing: Bool

    private lazy var session: URLSession = URLSessionFactory
        .urlSession { [weak self] delegateEvent in
            let event: WebSocketEvent
            switch delegateEvent {
            case .didOpen:
                event = .connected
            case .didClose(let closeCode):
                event = .disconnected(closeCode)
            case .didCompleteWithError(let error):
                event = .urlSessionCompletedTaskWithError(.failed(error))
            }
            self?.handleEvent(event)
        }

    public init(
        url: URL,
        handler: ((Event) -> Void)?,
        consoleLogger: ((String) -> Void)?,
        networkDebugLogger: NetworkDebugLogger,
        sendsPing: Bool = true
    ) {
        self.url = url
        self.handler = handler
        self.consoleLogger = consoleLogger
        self.networkDebugLogger = networkDebugLogger
        self.sendsPing = sendsPing
    }

    deinit {
        pingTimer?.invalidate()
        session.invalidateAndCancel()
    }

    public func open(_ requestBuilder: (URL) -> URLRequest = { URLRequest(url: $0, timeoutInterval: 30) }) {
        consoleLogger?("WebSocketConnection: Open \(url)")
        if task != nil {
            close(closeCode: .normalClosure)
        }
        let urlRequest = requestBuilder(url)
        loggerURLRequest = urlRequest
        task = session.webSocketTask(with: urlRequest)
        task?.resume()
        receive()
    }

    public func close(closeCode: URLSessionWebSocketTask.CloseCode) {
        pingTimer?.invalidate()
        task?.cancel(with: closeCode, reason: nil)
        task = nil
    }

    public func send(_ message: Message, onCompletion: (() -> Void)?) {
        consoleLogger?("WebSocketConnection: Send \(message)")
        task?.send(message.sessionMessage) { [weak self, consoleLogger] error in
            if let error {
                consoleLogger?("WebSocketConnection: Send failed \(message)")
                self?.handleEvent(.connnectionError(.failed(error)))
                onCompletion?()
            } else {
                consoleLogger?("WebSocketConnection: Send success \(message)")
                onCompletion?()
            }
        }
    }
}

extension WebSocketConnection {

    private func logNetworkReceive(result: Result<URLSessionWebSocketTask.Message, Error>) {
        consoleLogger?("WebSocketConnection: Receive")
        switch result {
        case .success(let message):
            consoleLogger?("WebSocketConnection: Receive Success \(message)")
        case .failure(let error):
            consoleLogger?("WebSocketConnection: Receive Error \(error)")
        }
        guard let loggerURLRequest else {
            return
        }
//        networkDebugLogger.storeRequest(loggerURLRequest, result: result, session: session)
    }

    private func receive() {
        consoleLogger?("WebSocketConnection: Receive Listen")
        task?.receive(
            completionHandler: { [weak self, logNetworkReceive] result in
                logNetworkReceive(result)
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let string):
                        self?.handleEvent(.received(.string(string)))
                    case .data(let data):
                        self?.handleEvent(.received(.data(data)))
                    @unknown default:
                        // No action
                        break
                    }
                    self?.receive()
                case .failure(let error):
                    self?.handleEvent(.connnectionError(.failed(error)))
                }
            }
        )
    }

    private func sendPing() {
        guard isConnected else {
            consoleLogger?("WebSocketConnection: Ping skip, not connected")
            return
        }
        consoleLogger?("WebSocketConnection: Ping")
        task?.sendPing { [weak self, consoleLogger] error in
            if let error {
                consoleLogger?("WebSocketConnection: Pong error \(error)")
                self?.handleEvent(.connnectionError(.failed(error)))
            } else {
                consoleLogger?("WebSocketConnection: Pong")
            }
        }
    }

    private func handleEvent(_ event: WebSocketEvent) {
        switch event {
        case .connected:
            consoleLogger?("WebSocketConnection: Handle connected")
            isConnected = true
            if sendsPing {
                DispatchQueue.main.async {
                    self.pingTimer = Timer.scheduledTimer(
                        withTimeInterval: 30,
                        repeats: true
                    ) { [weak self] _ in
                        self?.sendPing()
                    }
                }
            }
            handler?(.connected)
        case .disconnected(let closeCode):
            consoleLogger?("WebSocketConnection: Handle disconnected \(closeCode)")
            guard isConnected else { break }
            isConnected = false
            pingTimer?.invalidate()
            handler?(.disconnected(.closeCode(closeCode)))
        case .received(let message):
            consoleLogger?("WebSocketConnection: Handle received \(message)")
            handler?(.received(message))
        case .connnectionError(let error):
            consoleLogger?("WebSocketConnection: Handle connnectionError \(error)")
            handler?(.disconnected(.error(error)))
        case .urlSessionCompletedTaskWithError(let error):
            consoleLogger?("WebSocketConnection: URLSession completed task with \(error)")
            isConnected = false
            pingTimer?.invalidate()
            handler?(.recoverFromURLSessionCompletionError)
        }
    }

    public enum WebSocketError: Error, Equatable {
        case failed(Error)

        public static func == (lhs: WebSocketConnection.WebSocketError, rhs: WebSocketConnection.WebSocketError) -> Bool {
            switch (lhs, rhs) {
            case (.failed, .failed):
                return false
            }
        }
    }

    enum WebSocketEvent: Equatable {
        case connected
        case disconnected(URLSessionWebSocketTask.CloseCode)
        case received(Message)
        case connnectionError(WebSocketError)
        case urlSessionCompletedTaskWithError(WebSocketError)
    }

    public enum Message: Equatable {
        case data(Data)
        case string(String)

        var sessionMessage: URLSessionWebSocketTask.Message {
            switch self {
            case .data(let data):
                return .data(data)
            case .string(let string):
                return .string(string)
            }
        }
    }

    public enum DisconnectionData: Equatable {
        case error(WebSocketError)
        case closeCode(URLSessionWebSocketTask.CloseCode)
    }
}

extension WebSocketConnection {
    enum URLSessionFactory {
        static func urlSession(handler: @escaping (Delegate.Event) -> Void) -> URLSession {
            let delegate = Delegate()
            delegate.handler = handler
            let configuration = URLSessionConfiguration.default
            configuration.shouldUseExtendedBackgroundIdleMode = true
            configuration.waitsForConnectivity = true
            return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        }
    }

    final class Delegate: NSObject, URLSessionWebSocketDelegate {

        enum Event {
            case didOpen
            case didClose(URLSessionWebSocketTask.CloseCode)
            case didCompleteWithError(Error)
        }

        var handler: ((Delegate.Event) -> Void)?

        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didOpenWithProtocol protocol: String?
        ) {
            handler?(.didOpen)
        }

        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
            reason: Data?
        ) {
            handler?(.didClose(closeCode))
        }

        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didCompleteWithError error: Error?
        ) {
            if let error {
                handler?(.didCompleteWithError(error))
            }
        }
    }
}
