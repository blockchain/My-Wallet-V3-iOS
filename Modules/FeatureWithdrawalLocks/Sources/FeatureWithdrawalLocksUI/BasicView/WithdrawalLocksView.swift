// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureWithdrawalLocksDomain
import Localization
import SwiftUI
import UIComponentsKit

public struct WithdrawalLocksState: Hashable, NavigationState {
    public var route: RouteIntent<WithdrawalLocksRoute>?
    var withdrawalLocks: WithdrawalLocks?

    public init(route: RouteIntent<WithdrawalLocksRoute>? = nil, withdrawalLocks: WithdrawalLocks? = nil) {
        self.route = route
        self.withdrawalLocks = withdrawalLocks
    }
}

public enum WithdrawalLocksAction: Hashable, NavigationAction {
    case loadWithdrawalLocks
    case present(withdrawalLocks: WithdrawalLocks?)
    case route(RouteIntent<WithdrawalLocksRoute>?)
}

public enum WithdrawalLocksRoute: NavigationRoute {
    case details(withdrawalLocks: WithdrawalLocks)

    public func destination(in store: Store<WithdrawalLocksState, WithdrawalLocksAction>) -> some View {
        switch self {
        case .details(let withdrawalLocks):
            WithdrawalLocksDetailsView(withdrawalLocks: withdrawalLocks)
        }
    }
}

public struct WithdrawalLocksReducer: Reducer {

    public typealias State = WithdrawalLocksState
    public typealias Action = WithdrawalLocksAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let withdrawalLockService: WithdrawalLocksServiceAPI
    let updateViewAction: ((_ isVisible: Bool) -> Void)?

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        withdrawalLockService: WithdrawalLocksServiceAPI = resolve(),
        updateViewAction: ((_ isVisible: Bool) -> Void)?
    ) {
        self.mainQueue = mainQueue
        self.withdrawalLockService = withdrawalLockService
        self.updateViewAction = updateViewAction
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadWithdrawalLocks:
                return .publisher {
                    withdrawalLockService
                        .withdrawalLocks
                        .receive(on: mainQueue)
                        .map { withdrawalLocks in
                            .present(withdrawalLocks: withdrawalLocks)
                        }
                }
            case .present(withdrawalLocks: let withdrawalLocks):
                let updated = state.withdrawalLocks != withdrawalLocks
                state.withdrawalLocks = withdrawalLocks
                if updated {
                    updateViewAction?(
                        withdrawalLocks?.items.isEmpty == false
                    )
                }
                return .none
            case .route(let routeItent):
                state.route = routeItent
                return .none
            }
        }
    }
}

public struct WithdrawalLocksView: View {

    let store: Store<WithdrawalLocksState, WithdrawalLocksAction>

    public init(store: Store<WithdrawalLocksState, WithdrawalLocksAction>) {
        self.store = store
    }

    private typealias LocalizationIds = LocalizationConstants.WithdrawalLocks

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                if let withdrawalLocks = viewStore.state.withdrawalLocks, !withdrawalLocks.items.isEmpty {
                    Button {
                        viewStore.send(.enter(into: .details(withdrawalLocks: withdrawalLocks)))
                    } label: {
                        HStack {
                            Text(LocalizationIds.onHoldTitle)
                            if viewStore.state.withdrawalLocks?.items.isEmpty == false {
                                Icon.questionFilled
                                    .color(.semantic.muted)
                                    .frame(height: 14)
                            }
                            Spacer()

                            let amount = viewStore.withdrawalLocks?.amount
                            Text(amount ?? " ")
                                .shimmer(enabled: amount == nil, width: 50)
                        }
                        .foregroundColor(.semantic.body)
                        .typography(.paragraph2)
                        .padding()
                    }
                    .navigationRoute(in: store)
                } else {
                    EmptyView()
                }
            }
            .onAppear {
                viewStore.send(.loadWithdrawalLocks)
            }
        }
    }
}

// swiftlint:disable type_name
struct WithdrawalLocksView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            WithdrawalLocksView(store:
                Store(initialState: .init(withdrawalLocks: nil)) {
                    WithdrawalLocksReducer(
                        withdrawalLockService: NoOpWithdrawalLocksService(),
                        updateViewAction: nil
                    )
                }
            )
        }
    }
}
