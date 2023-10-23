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
                return .publisher {
                    plaidRepository
                        .getLinkToken()
                        .map { .getLinkTokenResponse($0) }
                        .catch { .finishedWithError($0) }
                        .receive(on: mainQueue)
                }

            case .getLinkTokenForExistingAccount(let accountId):
                return .publisher {
                    plaidRepository
                            .getLinkToken(accountId: accountId)
                            .map { .getLinkTokenResponse($0) }
                            .catch { .finishedWithError($0) }
                            .receive(on: mainQueue)
                }

            case .getLinkTokenResponse(let response):
                state.accountId = response.id
                app.post(
                    value: response.linkToken,
                    of: blockchain.ux.payment.method.plaid.event.receive.link.token
                )
                return Effect.send(.waitingForAccountLinkResult)

            case .waitingForAccountLinkResult:
                return .run { send in
                    do {
                        let event = try await app.on(blockchain.ux.payment.method.plaid.event.finished)
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
                return .publisher {
                    plaidRepository
                        .updatePlaidAccount(accountId, attributes: attribute)
                        .map { _ in .waitForActivation(accountId) }
                        .catch { .finishedWithError($0) }
                        .receive(on: mainQueue)
                }

            case .waitForActivation(let accountId):
                return .run { send in
                    try await plaidRepository
                        .waitForActivationOfLinkedBank(id: accountId)
                        .await()
                    await send(.updateSourceSelection)
                }

            case .updateSourceSelection:
                let accountId = state.accountId
                app.post(
                    event: blockchain.ux.payment.method.plaid.event.reload.linked_banks
                )
                app.post(
                    event: blockchain.ux.transaction.action.select.payment.method,
                    context: [
                        blockchain.ux.transaction.action.select.payment.method.id: accountId
                    ]
                )
                return Effect.send(.finished(success: true))

            case .finished(let success):
                dismissFlow(success)
                return .none

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
