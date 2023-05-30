// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BigInt
import Combine
import DIKit
import EthereumKit
import Foundation
import MoneyKit
import PlatformKit
import ToolKit
import WalletConnectSwift

final class RawTransactionRequestHandler: RequestHandler {

    private let accountProvider: WalletConnectAccountProviderAPI
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let getSession: (WCURL) -> Session?
    private let getNetwork: (Int) -> EVMNetwork?
    private let responseEvent: (WalletConnectResponseEvent) -> Void
    private let userEvent: (WalletConnectUserEvent) -> Void
    private var cancellables: Set<AnyCancellable> = []

    init(
        accountProvider: WalletConnectAccountProviderAPI = resolve(),
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        getSession: @escaping (WCURL) -> Session?,
        getNetwork: @escaping (Int) -> EVMNetwork?,
        responseEvent: @escaping (WalletConnectResponseEvent) -> Void,
        userEvent: @escaping (WalletConnectUserEvent) -> Void
    ) {
        self.accountProvider = accountProvider
        self.analyticsEventRecorder = analyticsEventRecorder
        self.enabledCurrenciesService = enabledCurrenciesService
        self.getSession = getSession
        self.getNetwork = getNetwork
        self.responseEvent = responseEvent
        self.userEvent = userEvent
    }

    func canHandle(request: Request) -> Bool {
        Method(rawValue: request.method) != nil
    }

    func handle(request: Request) {
        guard let session = getSession(request.url) else {
            responseEvent(.invalid(request))
            return
        }
        guard let chainID = session.walletInfo?.chainId else {
            // No chain ID
            responseEvent(.invalid(request))
            return
        }
        guard let network: EVMNetwork = getNetwork(chainID) else {
            // Chain not recognised.
            responseEvent(.invalid(request))
            return
        }
        guard enabledCurrenciesService.allEnabledCryptoCurrencies.contains(network.nativeAsset) else {
            // Chain recognised, but currently disabled.
            responseEvent(.invalid(request))
            return
        }

        accountProvider
            .defaultAccount(network: network)
            .map { [responseEvent, analyticsEventRecorder] defaultAccount -> WalletConnectUserEvent? in
                Self.createEvent(
                    analytics: analyticsEventRecorder,
                    defaultAccount: defaultAccount,
                    network: network,
                    request: request,
                    responseEvent: responseEvent,
                    session: session
                )
            }
            .sink(
                receiveValue: { [userEvent, responseEvent] event in
                    guard let event else {
                        responseEvent(.invalid(request))
                        return
                    }
                    userEvent(event)
                }
            )
            .store(in: &cancellables)
    }

    /// Creates a `WalletConnectUserEvent.sendTransaction(,)` from input data.
    private static func createEvent(
        analytics: AnalyticsEventRecorderAPI,
        defaultAccount: SingleAccount,
        network: EVMNetwork,
        request: Request,
        responseEvent: @escaping (WalletConnectResponseEvent) -> Void,
        session: Session
    ) -> WalletConnectUserEvent? {
        guard let method = Method(rawValue: request.method) else {
            return nil
        }
        guard let transaction = try? request.parameter(of: String.self, at: 0) else {
            return nil
        }
        let dAppName = session.dAppInfo.peerMeta.name
        let dAppAddress = session.dAppInfo.peerMeta.url.host ?? ""
        let dAppLogoURL = session.dAppInfo.peerMeta.icons.first?.absoluteString ?? ""

        let onTxCompleted: TransactionTarget.TxCompleted = { [analytics] transactionResult in
            analytics.record(
                event: method.analyticsEvent(
                    appName: dAppName,
                    action: .confirm
                )
            )
            switch transactionResult {
            case .signed(let string):
                responseEvent(.signature(string, request))
            case .hashed(let txHash, _):
                responseEvent(.transactionHash(txHash, request))
            case .unHashed:
                break
            }
            return .empty()
        }
        let onTransactionRejected: () -> AnyPublisher<Void, Never> = {
            responseEvent(.rejected(request))
            return .just(())
        }

        let target = EthereumRawTransactionTarget(
            dAppAddress: dAppAddress,
            dAppName: dAppName,
            dAppLogoURL: dAppLogoURL,
            rawTransaction: Data(hex: transaction),
            onTxCompleted: onTxCompleted,
            onTransactionRejected: onTransactionRejected
        )
        return .sendTransaction(defaultAccount, target)
    }
}

extension RawTransactionRequestHandler {

    private enum Method: String {
        case sendRawTransaction = "eth_sendRawTransaction"

        func analyticsEvent(
            appName: String,
            action: AnalyticsEvents.New.WalletConnect.Action
        ) -> AnalyticsEvent {
            switch self {
            case .sendRawTransaction:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .sendRawTransaction
                    )
            }
        }
    }
}
