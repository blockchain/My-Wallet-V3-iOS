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

final class SignRequestHandler: RequestHandler {

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

    /// Creates a `WalletConnectUserEvent.signMessage(,)` from input data.`
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
        guard let address = method.address(request: request) else {
            return nil
        }
        guard let message = method.message(request: request) else {
            return nil
        }
        let dAppName = session.dAppInfo.peerMeta.name
        let dAppAddress = session.dAppInfo.peerMeta.url.host ?? ""
        let dAppLogoURL = session.dAppInfo.peerMeta.icons.first?.absoluteString ?? ""

        let onTransactionRejected: () -> AnyPublisher<Void, Never> = {
            responseEvent(.rejected(request))
            return .just(())
        }
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
        let target = EthereumSignMessageTarget(
            account: address,
            dAppAddress: dAppAddress,
            dAppLogoURL: dAppLogoURL,
            dAppName: dAppName,
            message: message,
            network: network,
            onTransactionRejected: onTransactionRejected,
            onTxCompleted: onTxCompleted
        )
        return .signMessage(defaultAccount, target)
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
            guard let messageData = try? request.parameter(of: String.self, at: dataIndex) else {
                return nil
            }
            switch self {
            case .ethSign,
                 .personalSign:
                return .data(Data(hex: messageData))
            case .ethSignTypedData:
                return .typedData(messageData)
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
