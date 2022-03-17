// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import PlatformKit
import WalletConnectSwift

final class SignRequestHandler: RequestHandler {

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
                guard let address = method.address(request: request) else {
                    return nil
                }
                guard let message = method.message(request: request) else {
                    return nil
                }
                let dAppName = session.dAppInfo.peerMeta.name
                let target = EthereumSignMessageTarget(
                    dAppAddress: session.dAppInfo.peerMeta.url.host ?? "",
                    dAppName: dAppName,
                    dAppLogoURL: session.dAppInfo.peerMeta.icons.first?.absoluteString ?? "",
                    account: address,
                    message: message,
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
                return .signMessage(defaultAccount, target)
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

extension SignRequestHandler {

    private enum Method: String {
        case personalSign = "personal_sign"
        case ethSign = "eth_sign"
        case ethSignTypedData = "eth_signTypedData"

        private var dataIndex: Int {
            switch self {
            case .personalSign:
                return 0
            case .ethSign, .ethSignTypedData:
                return 1
            }
        }

        private var addressIndex: Int {
            switch self {
            case .personalSign:
                return 1
            case .ethSign, .ethSignTypedData:
                return 0
            }
        }

        func address(request: Request) -> String? {
            try? request.parameter(of: String.self, at: addressIndex)
        }

        func message(request: Request) -> EthereumSignMessageTarget.Message? {
            switch self {
            case .ethSign,
                 .personalSign:
                guard let messageBytes = try? request.parameter(of: String.self, at: dataIndex) else {
                    return nil
                }
                return .data(Data(hex: messageBytes))
            case .ethSignTypedData:
                guard let typedData = try? request.parameterJson(at: dataIndex) else {
                    return nil
                }
                return .typedData(typedData)
            }
        }

        func analyticsEvent(
            appName: String,
            action: AnalyticsEvents.New.WalletConnect.Action
        ) -> AnalyticsEvent {
            switch self {
            case .ethSign:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .sign
                    )
            case .ethSignTypedData:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .signTypedData
                    )
            case .personalSign:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .personalSign
                    )
            }
        }
    }
}
