// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Errors
import FeaturePlaidDomain
import Foundation

public struct PlaidReducer: Reducer {

    public typealias State = PlaidState
    public typealias Action = PlaidAction

    public let app: AppProtocol
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let plaidRepository: PlaidRepositoryAPI
    public let dismissFlow: (Bool) -> Void

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        plaidRepository: PlaidRepositoryAPI,
        dismissFlow: @escaping (Bool) -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.plaidRepository = plaidRepository
        self.dismissFlow = dismissFlow
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let accountId = state.accountId else {
                    return Effect.send(.startLinkingNewBank)
                }
                return Effect.send(.getLinkTokenForExistingAccount(accountId))

            case .startLinkingNewBank:
                return .run { send in
                    do {
                        let accountInfo = try await plaidRepository
                            .getLinkToken()
                            .receive(on: mainQueue).await()
                        await send(.getLinkTokenResponse(accountInfo))
                    } catch {
                        await send(.finishedWithError(error as? NabuError))
                    }
                }

            case .getLinkTokenForExistingAccount(let accountId):
                return .run { send in
                    do {
                        let accountInfo = try await plaidRepository
                            .getLinkToken(accountId: accountId)
                            .receive(on: mainQueue)
                            .await()
                        await send(.getLinkTokenResponse(accountInfo))
                    } catch {
                        await send(.finishedWithError(error as? NabuError))
                    }
                }

            case .getLinkTokenResponse(let response):
                state.accountId = response.id
                return .merge(
                    .run { _ in
                        // post blockchain event with received token so
                        // LinkKit SDK can act on it
                        app.post(
                            value: response.linkToken,
                            of: blockchain.ux.payment.method.plaid.event.receive.link.token
                        )
                    },
                    Effect.send(.waitingForAccountLinkResult)
                )

            case .waitingForAccountLinkResult:
                return .run { send in
                    do {
                        let event = try await app.on(blockchain.ux.payment.method.plaid.event.finished)
                            .receive(on: mainQueue)
                            .map { event -> PlaidAction in
                                do {
                                    let success = blockchain.ux.payment.method.plaid.event.receive.success
                                    return try .update(
                                        PlaidAccountAttributes(
                                            accountId: event.context.decode(success.id),
                                            publicToken: event.context.decode(success.token)
                                        )
                                    )
                                } catch {
                                    // User dismissed the flow
                                    return .finished(success: false)
                                }
                            }
                            .await()
                            
                        await send(event)
                    } catch {
                        await send(.finished(success: false))
                    }
                }

            case .update(let attribute):
                guard let accountId = state.accountId else {
                    // This should not happen
                    return Effect.send(.finishedWithError(nil))
                }
                return .run { send in
                    do {
                        try await plaidRepository
                            .updatePlaidAccount(accountId, attributes: attribute)
                            .receive(on: mainQueue)
                            .await()
                        await send(.waitForActivation(accountId))
                    } catch {
                        await send(.finishedWithError(error as? NabuError))
                    }
                }

            case .waitForActivation(let accountId):
                return .run { send in
                    try await plaidRepository
                        .waitForActivationOfLinkedBank(id: accountId)
                        .receive(on: mainQueue)
                        .await()
                    await send(.updateSourceSelection)
                }

            case .updateSourceSelection:
                let accountId = state.accountId
                return .merge(
                    .run { _ in
                        // Update the transaction source
                        app.post(
                            event: blockchain.ux.payment.method.plaid.event.reload.linked_banks
                        )
                        app.post(
                            event: blockchain.ux.transaction.action.select.payment.method,
                            context: [
                                blockchain.ux.transaction.action.select.payment.method.id: accountId
                            ]
                        )
                    },
                    Effect.send(.finished(success: true))
                )

            case .finished(let success):
                return .run { _ in
                    dismissFlow(success)
                }

            case .finishedWithError(let error):
                if let error {
                    state.uxError = UX.Error(nabu: error)
                } else {
                    // Oops message
                    state.uxError = UX.Error(error: nil)
                }
                return .none
            }
        }
    }
}
