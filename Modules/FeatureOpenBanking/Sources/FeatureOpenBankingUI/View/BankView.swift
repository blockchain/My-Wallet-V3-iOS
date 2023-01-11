// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import FeatureOpenBankingDomain
import SwiftUI
import UIComponentsKit

// swiftlint:disable type_name

public struct BankState: Equatable {

    public struct UI: Equatable {

        public enum Action: Hashable {
            case retry(label: String, action: BankAction)
            case next
            case ok
            case cancel
        }

        public var info: InfoView.Model
        public internal(set) var action: [Action]?
    }

    public internal(set) var error: UX.Dialog?
    public internal(set) var ui: UI?
    public internal(set) var data: OpenBanking.Data
    public var showActions: Bool = false

    var account: OpenBanking.BankAccount { data.account }

    var name: String {
        switch data.action {
        case .link(let institution):
            return institution.fullName
        case .deposit, .confirm:
            return account.details?.bankName ?? Localization.Bank.yourBank
        }
    }

    var currency: String? {
        switch data.action {
        case .link, .deposit:
            return account.currency
        case .confirm(order: let order):
            return order.outputCurrency
        }
    }
}

public enum BankAction: Hashable, FailureAction {
    case retry
    case request
    case showActions
    case launchAuthorisation(URL)
    case waitingForConsent
    case finalise(OpenBanking.Output)
    case cancel
    case dismiss
    case finished
    case failure(OpenBanking.Error)
}

public let bankReducer = Reducer<BankState, BankAction, OpenBankingEnvironment> { state, action, environment in

    enum ID {
        struct Request: Hashable {}
        struct LaunchBank: Hashable {}
        struct ConsentError: Hashable {}
    }

    switch action {
    case .retry:
        return .merge(
            .cancel(id: ID.Request()),
            .cancel(id: ID.LaunchBank()),
            Effect(value: .request)
        )
    case .request:
        state.ui = .communicating(to: state.name)
        state.showActions = false
        return .merge(
            Just(())
                .delay(for: .seconds(90), scheduler: environment.scheduler)
                .eraseToEffect()
                .map { BankAction.showActions },
            .fireAndForget {
                environment.openBanking.reset()
            },
            environment.openBanking.start(state.data)
                .compactMap { state -> BankAction in
                    switch state {
                    case .waitingForConsent:
                        return .waitingForConsent
                    case .success(let output):
                        return .finalise(output)
                    case .fail(let error):
                        return BankAction.failure(error)
                    }
                }
                .receive(on: environment.scheduler)
                .eraseToEffect()
                .cancellable(id: ID.Request()),
            environment.openBanking.authorisationURLPublisher
                .map(BankAction.launchAuthorisation)
                .receive(on: environment.scheduler)
                .eraseToEffect()
                .cancellable(id: ID.LaunchBank())
        )
    case .showActions:
        state.showActions = true
        return .none

    case .waitingForConsent:
        state.ui = .waiting(for: state.name)
        return .none

    case .launchAuthorisation(let url):
        state.ui = .waiting(for: state.name)
        return .merge(
            .fireAndForget { environment.openURL.open(url) },
            .cancel(id: ID.LaunchBank())
        )

    case .finalise(let output):
        state.showActions = true
        switch output {
        case .linked(let account, let institution):
            state.ui = .linked(institution: state.name)
            return .merge(
                .cancel(id: ID.ConsentError()),
                .cancel(id: ID.Request()),
                .cancel(id: ID.LaunchBank())
            )
        case .deposited(let payment):
            state.ui = .deposit(success: payment, in: environment)
        case .confirmed(let order) where order.state == .finished:
            state.ui = .buy(finished: order, in: environment)
        case .confirmed(let order):
            state.ui = .buy(pending: order, in: environment)
        }
        return .merge(
            .cancel(id: ID.ConsentError()),
            .cancel(id: ID.Request()),
            .cancel(id: ID.LaunchBank())
        )

    case .dismiss:
        return .fireAndForget(environment.dismiss)

    case .finished, .cancel:
        return .merge(
            .cancel(id: ID.ConsentError()),
            .cancel(id: ID.Request()),
            .cancel(id: ID.LaunchBank())
        )

    case .failure(let error):
        state.showActions = true
        switch error {
        case .timeout:
            state.ui = .pending()
        case .ux(let error):
            state.error = error
        default:
            state.ui = .error(error, currency: state.currency, in: environment)
        }
        return .cancel(id: ID.ConsentError())
    }
}
.analytics()

extension Reducer where State == BankState, Action == BankAction, Environment == OpenBankingEnvironment {

    func analytics() -> Self {
        combined(
            with: .init { _, action, environment in
                switch action {
                case .failure(let error):
                    return .fireAndForget {
                        environment.analytics.record(
                            event: ClientEvent.clientError(
                                id: error.code,
                                error: BankState.UI.errors[error] != nil
                                    ? "OPEN_BANKING_ERROR"
                                    : "OPEN_BANKING_OOPS_ERROR",
                                networkEndpoint: nil,
                                networkErrorCode: nil,
                                networkErrorDescription: error.description,
                                networkErrorId: nil,
                                networkErrorType: error.code,
                                source: error.code == nil ? "CLIENT" : "NABU",
                                title: error.description
                            )
                        )
                    }
                default:
                    return .none
                }
            }
        )
    }
}

public struct BankView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    private let store: Store<BankState, BankAction>

    public init(store: Store<BankState, BankAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            if let ux = viewStore.error {
                ErrorView(
                    ux: UX.Error(nabu: ux),
                    dismiss: { viewStore.send(.dismiss) }
                )
            } else if let ui = viewStore.ui {
                ActionableView(
                    ui.info,
                    buttons: viewStore.showActions ? buttons(from: ui.action, in: viewStore) : []
                )
                .trailingNavigationButton(.close) {
                    viewStore.send(.dismiss)
                }
            } else {
                ProgressView(value: 0.25)
                    .progressViewStyle(IndeterminateProgressStyle())
                    .onAppear {
                        viewStore.send(.request)
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
        .whiteNavigationBarStyle()
        .background(Color.semantic.background)
    }

    private typealias ButtonState = ActionableViewButtonState

    private func buttons(
        from actions: [BankState.UI.Action]?,
        in viewStore: ViewStore<BankState, BankAction>
    ) -> [ButtonState] {
        guard let actions else { return [] }
        return actions
            .enumerated()
            .map { i, action in
                let style: ButtonState.Style = i == 0 ? .primary : .secondary
                let tap = i == 0 ? \L_blockchain_ui_type_task_paragraph_button.primary.tap : \L_blockchain_ui_type_task_paragraph_button.secondary.tap
                switch action {
                case .ok:
                    return .init(
                        title: Localization.Bank.Action.ok,
                        action: {
                            $app.post(event: blockchain.ux.payment.method.open.banking.waiting.for.bank.ok.paragraph.button[keyPath: tap])
                            viewStore.send(.finished)
                        },
                        style: style
                    )
                case .next:
                    return .init(
                        title: Localization.Bank.Action.next,
                        action: {
                            $app.post(event: blockchain.ux.payment.method.open.banking.waiting.for.bank.next.paragraph.button[keyPath: tap])
                            viewStore.send(.finished)
                        },
                        style: style
                    )
                case .retry(let label, let action):
                    return .init(
                        title: label,
                        action: {
                            $app.post(event: blockchain.ux.payment.method.open.banking.waiting.for.bank.retry.paragraph.button[keyPath: tap])
                            viewStore.send(action)
                        },
                        style: style
                    )
                case .cancel:
                    return .init(
                        title: Localization.Bank.Action.cancel,
                        action: {
                            $app.post(event: blockchain.ux.payment.method.open.banking.waiting.for.bank.cancel.paragraph.button[keyPath: tap])
                            viewStore.send(.cancel)
                        },
                        style: style
                    )
                }
            }
    }
}

#if DEBUG
struct BankView_Previews: PreviewProvider {

    static var previews: some View {
        BankView(
            store: .init(
                initialState: BankState(
                    ui: .linked(institution: "Monzo"),
                    data: .init(
                        account: .mock,
                        action: .link(institution: .mock)
                    )
                ),
                reducer: bankReducer,
                environment: .mock
            )
        )
    }
}
#endif
