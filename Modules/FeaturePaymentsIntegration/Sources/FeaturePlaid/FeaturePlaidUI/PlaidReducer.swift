// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Errors
import FeaturePlaidDomain

public enum PlaidModule {}

extension PlaidModule {
    public static var reducer: Reducer<PlaidState, PlaidAction, PlaidEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onAppear:
                guard let accountId = state.accountId else {
                    return EffectTask(value: .startLinkingNewBank)
                }
                return EffectTask(value: .getLinkTokenForExistingAccount(accountId))

            case .startLinkingNewBank:
                return environment
                    .plaidRepository
                    .getLinkToken()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> PlaidAction in
                        switch result {
                        case .success(let accountInfo):
                            return .getLinkTokenResponse(accountInfo)
                        case .failure(let error):
                            return .finishedWithError(error)
                        }
                    }

            case .getLinkTokenForExistingAccount(let accountId):
                return environment
                    .plaidRepository
                    .getLinkToken(accountId: accountId)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> PlaidAction in
                        switch result {
                        case .success(let accountInfo):
                            return .getLinkTokenResponse(accountInfo)
                        case .failure(let error):
                            return .finishedWithError(error)
                        }
                    }

            case .getLinkTokenResponse(let response):
                state.accountId = response.id
                return .merge(
                    .fireAndForget {
                        // post blockchain event with received token so
                        // LinkKit SDK can act on it
                        environment.app.post(
                            value: response.linkToken,
                            of: blockchain.ux.payment.method.plaid.event.receive.link.token
                        )
                    },
                    EffectTask(value: .waitingForAccountLinkResult)
                )

            case .waitingForAccountLinkResult:
                return environment.app.on(blockchain.ux.payment.method.plaid.event.finished)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
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

            case .update(let attribute):
                guard let accountId = state.accountId else {
                    // This should not happen
                    return EffectTask(value: .finishedWithError(nil))
                }
                return environment
                    .plaidRepository
                    .updatePlaidAccount(accountId, attributes: attribute)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> PlaidAction in
                        switch result {
                        case .success:
                            return .waitForActivation(accountId)
                        case .failure(let error):
                            return .finishedWithError(error)
                        }
                    }

            case .waitForActivation(let accountId):
                return environment
                    .plaidRepository
                    .waitForActivationOfLinkedBank(id: accountId)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { _ in .updateSourceSelection }

            case .updateSourceSelection:
                let accountId = state.accountId
                return .merge(
                    .fireAndForget {
                        // Update the transaction source
                        environment.app.post(
                            event: blockchain.ux.payment.method.plaid.event.reload.linked_banks
                        )
                        environment.app.post(
                            event: blockchain.ux.transaction.action.select.payment.method,
                            context: [
                                blockchain.ux.transaction.action.select.payment.method.id: accountId
                            ]
                        )
                    },
                    EffectTask(value: .finished(success: true))
                )

            case .finished(let success):
                return .fireAndForget {
                    environment.dismissFlow(success)
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
