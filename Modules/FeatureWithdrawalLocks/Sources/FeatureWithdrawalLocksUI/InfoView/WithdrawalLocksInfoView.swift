// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureWithdrawalLocksDomain
import Localization
import SwiftUI

public struct WithdrawalLocksInfoState: Hashable, NavigationState {
    public var route: RouteIntent<WithdrawalLocksInfoRoute>?
    public var withdrawalLocks: WithdrawalLocks?
    public let amountAvailable: String

    public init(amountAvailable: String) {
        self.amountAvailable = amountAvailable
    }
}

public enum WithdrawalLocksInfoAction: Hashable, NavigationAction {
    case loadWithdrawalLocks
    case dismiss
    case present(withdrawalLocks: WithdrawalLocks?)
    case route(RouteIntent<WithdrawalLocksInfoRoute>?)
}

public enum WithdrawalLocksInfoRoute: NavigationRoute {
    case details(withdrawalLocks: WithdrawalLocks)

    public func destination(in store: Store<WithdrawalLocksInfoState, WithdrawalLocksInfoAction>) -> some View {
        switch self {
        case .details(let withdrawalLocks):
            WithdrawalLocksDetailsView(withdrawalLocks: withdrawalLocks)
        }
    }
}

public struct WithdrawalLockInfoReducer: Reducer {

    public typealias State = WithdrawalLocksInfoState
    public typealias Action = WithdrawalLocksInfoAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let withdrawalLockService: WithdrawalLocksServiceAPI
    let closeAction: (() -> Void)?

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        withdrawalLockService: WithdrawalLocksServiceAPI = resolve(),
        closeAction: (() -> Void)? = nil
    ) {
        self.mainQueue = mainQueue
        self.withdrawalLockService = withdrawalLockService
        self.closeAction = closeAction
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
                state.withdrawalLocks = withdrawalLocks
                return .none
            case .route(let routeItent):
                state.route = routeItent
                return .none
            case .dismiss:
                closeAction?()
                return .none
            }
        }
    }
}

public struct WithdrawalLocksInfoView: View {

    let store: Store<WithdrawalLocksInfoState, WithdrawalLocksInfoAction>

    private typealias LocalizationIds = LocalizationConstants.WithdrawalLocks

    public init(store: Store<WithdrawalLocksInfoState, WithdrawalLocksInfoAction>) {
        self.store = store
    }

    @Environment(\.openURL) private var openURL

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .top) {
                HStack {
                    Spacer()
                    IconButton(icon: .navigationCloseButton()) {
                        viewStore.send(.dismiss)
                    }
                    .frame(width: 24, height: 24)
                }
                .padding([.trailing, .top])

                VStack {
                    Icon.pending
                        .body
                        .frame(height: 60)

                    if let amount = viewStore.withdrawalLocks?.amount {
                        Text(String(format: LocalizationIds.onHoldAmountTitle, amount))
                            .typography(.title3)
                            .padding(.top, 24.pt)
                    } else {
                        Text(" ")
                            .typography(.title3)
                            .padding(.top, 24.pt)
                            .shimmer(enabled: true, width: 100)
                    }

                    Text(LocalizationIds.holdingPeriodDescription)
                        .typography(.paragraph1)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing, .top], 24.pt)

                    Text(LocalizationIds.learnMoreTitle)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.primary)
                        .onTapGesture {
                            openURL(Constants.withdrawalLocksSupportUrl)
                        }
                        .padding()

                    PrimaryDivider()
                    HStack {
                        Text(LocalizationIds.availableToWithdrawTitle)
                        Spacer()
                        Text(viewStore.amountAvailable)
                    }
                    .foregroundColor(.semantic.body)
                    .typography(.paragraph2)
                    .frame(height: 44)
                    .padding([.leading, .trailing])

                    PrimaryDivider()

                    Spacer()

                    MinimalButton(title: LocalizationIds.seeDetailsButtonTitle) {
                        if let withdrawalLocks = viewStore.state.withdrawalLocks {
                            viewStore.send(.enter(into: .details(withdrawalLocks: withdrawalLocks)))
                        }
                    }
                    .navigationRoute(in: store)
                    .padding()

                    PrimaryButton(title: LocalizationIds.confirmButtonTitle) {
                        viewStore.send(.dismiss)
                    }
                    .padding([.leading, .trailing, .bottom])
                }
                .padding(.top, 70.pt)
            }
            .onAppear {
                viewStore.send(.loadWithdrawalLocks)
            }
            .navigationBarHidden(true)
        }
    }
}

// swiftlint:disable type_name
struct WithdrawalLocksInfoView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            WithdrawalLocksInfoView(store:
                Store(initialState: .init(amountAvailable: "$191.12")) {
                    WithdrawalLockInfoReducer(
                        withdrawalLockService: NoOpWithdrawalLocksService()
                    )
                }
            )
        }
    }
}
