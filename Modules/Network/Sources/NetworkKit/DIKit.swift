// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
@_exported import Errors
import Foundation

public enum DIKitContext: String {
    case explorer
    case wallet
    case retail
    case everypay
    case websocket
}

extension DependencyContainer {

    // MARK: - NetworkKit Module

    public static var networkKit = module {

        factory { CertificateProvider() as CertificateProviderAPI }

        factory { BlockchainAPI.shared }

        factory { UserAgentProvider() }

        single { CertificatePinner() as CertificatePinnerAPI }

        single { SessionDelegate() as SessionDelegateAPI }

        single { URLSessionConfiguration.defaultConfiguration() }

        single { URLSession.defaultSession() }

        single { BlockchainNetworkCommunicatorSessionHandler() as NetworkSessionDelegateAPI }

        single { Network.Config.defaultConfig }

        factory { () -> APICode in
            let config: Network.Config = DIKit.resolve()
            return config.apiCode as APICode
        }

        single { NetworkResponseDecoder() as NetworkResponseDecoderAPI }

        single { RequestBuilder() }

        single { BaseRequestBuilder() }

        single { NetworkResponseHandler() as NetworkResponseHandlerAPI }

        single { NetworkAdapter.defaultAdapter() as NetworkAdapterAPI }

        single { NetworkCommunicator.defaultCommunicator() as NetworkCommunicatorAPI }

        // MARK: - Websocket

        single(tag: DIKitContext.websocket) {
            RequestBuilder(
                config: Network.Config.websocketConfig
            )
        }

        // MARK: - Explorer

        single(tag: DIKitContext.explorer) {
            RequestBuilder(
                config: Network.Config.explorerConfig,
                resolveHeaders: DIKit.resolve(tag: HTTPHeaderTag)
            )
        }

        single(tag: DIKitContext.explorer) { NetworkAdapter() as NetworkAdapterAPI }

        // MARK: - Wallet

        single(tag: DIKitContext.wallet) {
            RequestBuilder(
                config: Network.Config.walletConfig,
                resolveHeaders: DIKit.resolve(tag: HTTPHeaderTag)
            )
        }

        single(tag: DIKitContext.wallet) { NetworkAdapter() as NetworkAdapterAPI }

        // MARK: - Retail

        single(tag: DIKitContext.retail) {
            RequestBuilder(
                config: Network.Config.retailConfig,
                resolveHeaders: DIKit.resolve(tag: HTTPHeaderTag),
                queryParameters: DIKit.resolve()
            )
        }

        single(tag: DIKitContext.retail) { NetworkAdapter.retailAdapter() as NetworkAdapterAPI }

        single(tag: DIKitContext.retail) { NetworkCommunicator.retailCommunicator() as NetworkCommunicatorAPI }

        // MARK: - EveryPay

        single(tag: DIKitContext.everypay) { DefaultSessionHandler() as NetworkSessionDelegateAPI }

        single(tag: DIKitContext.everypay) { RequestBuilder(config: Network.Config.everypayConfig) }

        single(tag: DIKitContext.everypay) { NetworkAdapter.everypayAdapter() as NetworkAdapterAPI }

        single(tag: DIKitContext.everypay) { NetworkCommunicator.everypayCommunicator() as NetworkCommunicatorAPI }

        single { () -> NetworkSession in
            let session: URLSession = DIKit.resolve()
            return session as NetworkSession
        }
    }
}

extension NetworkCommunicator {

    fileprivate static func defaultCommunicator(
        eventRecorder: AnalyticsEventRecorderAPI = resolve()
    ) -> NetworkCommunicator {
        NetworkCommunicator(eventRecorder: eventRecorder)
    }

    fileprivate static func retailCommunicator(
        authenticator: AuthenticatorAPI = resolve()
    ) -> NetworkCommunicator {
        NetworkCommunicator(authenticator: authenticator)
    }

    fileprivate static func everypayCommunicator(
        sessionHandler: NetworkSessionDelegateAPI = resolve(tag: DIKitContext.everypay)
    ) -> NetworkCommunicator {
        NetworkCommunicator(sessionHandler: sessionHandler)
    }
}

extension NetworkAdapter {

    fileprivate static func defaultAdapter(
        communicator: NetworkCommunicatorAPI = resolve()
    ) -> NetworkAdapter {
        NetworkAdapter(communicator: communicator)
    }

    fileprivate static func retailAdapter(
        communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail)
    ) -> NetworkAdapter {
        NetworkAdapter(communicator: communicator)
    }

    fileprivate static func everypayAdapter(
        communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.everypay)
    ) -> NetworkAdapter {
        NetworkAdapter(communicator: communicator)
    }
}

extension URLSession {

    fileprivate static func defaultSession(
        with configuration: URLSessionConfiguration = resolve(),
        sessionDelegate delegate: SessionDelegateAPI = resolve(),
        delegateQueue queue: OperationQueue? = nil
    ) -> URLSession {
        URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
    }
}

extension URLSessionConfiguration {

    fileprivate static func defaultConfiguration(
        userAgentProvider: UserAgentProvider = resolve()
    ) -> URLSessionConfiguration {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = [
            HttpHeaderField.userAgent: userAgentProvider.userAgent!
        ]
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.httpMaximumConnectionsPerHost = 10
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.timeoutIntervalForResource = 300

        return sessionConfiguration
    }
}
