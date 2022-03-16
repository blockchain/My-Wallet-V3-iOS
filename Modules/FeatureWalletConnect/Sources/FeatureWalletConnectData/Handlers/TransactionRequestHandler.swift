// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import PlatformKit
import WalletConnectSwift

final class TransactionRequestHandler: RequestHandler {

    private let accountProvider: WalletConnectAccountProviderAPI
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let userEvent: (WalletConnectUserEvent) -> Void
    private let responseEvent: (WalletConnectResponseEvent) -> Void
    private var cancellables: Set<AnyCancellable> = []
    private let getSession: (WCURL) -> Session?

    init(
        accountProvider: WalletConnectAccountProviderAPI = resolve(),
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        userEvent: @escaping (WalletConnectUserEvent) -> Void,
        responseEvent: @escaping (WalletConnectResponseEvent) -> Void,
        getSession: @escaping (WCURL) -> Session?
    ) {
        self.accountProvider = accountProvider
        self.analyticsEventRecorder = analyticsEventRecorder
        self.userEvent = userEvent
        self.responseEvent = responseEvent
        self.getSession = getSession
    }

    func canHandle(request: Request) -> Bool {
        Method(rawValue: request.method) != nil
    }

    func handle(request: Request) {
        accountProvider
            .defaultAccount
            .map { [responseEvent, getSession, analyticsEventRecorder] defaultAccount
                -> WalletConnectUserEvent? in
                guard let method = Method(rawValue: request.method) else {
                    return nil
                }
                guard let session = getSession(request.url) else {
                    return nil
                }
                guard let transaction = try? request.parameter(of: EthereumJsonRpcTransaction.self, at: 0) else {
                    return nil
                }
                let dAppName = session.dAppInfo.peerMeta.name
                let target = EthereumSendTransactionTarget(
                    dAppAddress: session.dAppInfo.peerMeta.url.host ?? "",
                    dAppName: dAppName,
                    dAppLogoURL: session.dAppInfo.peerMeta.icons.first?.absoluteString ?? "",
                    transaction: transaction,
                    method: method.targetMethod,
                    onTxCompleted: { [analyticsEventRecorder] transactionResult in
                        analyticsEventRecorder.record(
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
                    },
                    onTransactionRejected: {
                        responseEvent(.rejected(request))
                        return .just(())
                    }
                )
                return method.userEvent(
                    account: defaultAccount,
                    target: target
                )
            }
            .sink(
                receiveValue: { [userEvent, responseEvent] event in
                    guard let event = event else {
                        responseEvent(.invalid(request))
                        return
                    }
                    userEvent(event)
                }
            )
            .store(in: &cancellables)
    }
}

extension TransactionRequestHandler {

    private enum Method: String {
        case sendTransaction = "eth_sendTransaction"
        case signTransaction = "eth_signTransaction"

        var targetMethod: EthereumSendTransactionTarget.Method {
            switch self {
            case .sendTransaction:
                return .send
            case .signTransaction:
                return .sign
            }
        }

        func userEvent(
            account: SingleAccount,
            target: EthereumSendTransactionTarget
        ) -> WalletConnectUserEvent {
            switch self {
            case .sendTransaction:
                return .sendTransaction(account, target)
            case .signTransaction:
                return .signTransaction(account, target)
            }
        }

        func analyticsEvent(
            appName: String,
            action: AnalyticsEvents.New.WalletConnect.Action
        ) -> AnalyticsEvent {
            switch self {
            case .sendTransaction:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .sendTransaction
                    )
            case .signTransaction:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .signTransaction
                    )
            }
        }
    }
}
