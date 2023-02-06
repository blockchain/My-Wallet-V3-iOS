//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
import Pulse
import PulseUI
#endif

import BlockchainNamespace
import Combine
import FeatureDebugUI
import NetworkKit
import SwiftUI

#if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
final class PulseBlockchainNamespaceEventLogger: Client.Observer {

    typealias Logger = Pulse.LoggerStore

    unowned var app: AppProtocol

    var pulse: Logger = .shared

    private var subscription: BlockchainEventSubscription? {
        didSet { subscription?.start() }
    }

    init(app: AppProtocol) {
        self.app = app
    }

    func start() {
        subscription = app.on(blockchain.ux.type.analytics.event) { @MainActor [pulse] event async in
            pulse.storeMessage(
                label: "namespace",
                level: .info,
                message: event.description,
                metadata: event.context.mapKeysAndValues(
                    key: \.description,
                    value: String.init(describing:)
                )
                .mapValues(Logger.MetadataValue.string),
                file: event.reference.context[
                    blockchain.ux.type.analytics.event.source.file
                ] as? String ?? event.source.file,
                function: "App.post(event:context:)",
                line: UInt(event.reference.context[
                    blockchain.ux.type.analytics.event.source.line
                ] as? Int ?? event.source.line)
            )
        }
    }

    func stop() {
        subscription = nil
    }
}
#endif

final class PulseNetworkDebugLogger: NetworkDebugLogger {

    // swiftlint:disable function_parameter_count
    func storeRequest(
        _ request: URLRequest,
        response: URLResponse?,
        error: Error?,
        data: Data?,
        metrics: URLSessionTaskMetrics?,
        session: URLSession?
    ) {
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        LoggerStore.shared.storeRequest(
            request,
            response: response,
            error: error,
            data: data,
            metrics: metrics
        )
        #endif
    }

    func storeRequest(
        _ request: URLRequest,
        result: Result<URLSessionWebSocketTask.Message, Error>,
        session: URLSession?
    ) {
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        switch result {
        case .success(let message):
            switch message {
            case .data(let data):
                storeRequest(
                    request,
                    response: nil,
                    error: nil,
                    data: data,
                    metrics: nil,
                    session: session
                )
            case .string(let string):
                storeRequest(
                    request,
                    response: nil,
                    error: nil,
                    data: string.data(using: .utf8),
                    metrics: nil,
                    session: session
                )
            @unknown default:
                // No action
                break
            }
        case .failure(let failure):
            storeRequest(
                request,
                response: nil,
                error: failure,
                data: nil,
                metrics: nil,
                session: session
            )
        }
        #endif
    }
}

final class PulseNetworkDebugScreenProvider: NetworkDebugScreenProvider {
    @ViewBuilder func buildDebugView() -> AnyView {
    #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        AnyView(ConsoleView())
    #else
        AnyView(EmptyView())
    #endif
    }
}
