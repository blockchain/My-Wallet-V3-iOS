// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import Localization
import MoneyKit
import PlatformKit
import SwiftUI
import UIComponentsKit

// MARK: - State

public struct AvailableBalanceViewState: Equatable {
    var balance: FiatValue?
    var availableBalance: FiatValue?
    var fees: FiatValue?
    var action: AssetAction?

    var isDataPopulated: Bool {
        balance != nil &&
        availableBalance != nil &&
        fees != nil &&
        action != nil
    }

    public init(
        balance: FiatValue? = nil,
        availableBalance: FiatValue? = nil,
        fees: FiatValue? = nil,
        action: AssetAction? = nil
    ) {
        self.fees = fees
        self.action = action
        self.availableBalance = availableBalance
        self.balance = balance
    }
}

// MARK: - Actions

public enum AvailableBalanceViewAction: Equatable {
    case onAppear
    case updateBalance(FiatValue)
    case updateAvailableBalance(FiatValue)
    case updateFees(FiatValue)
    case updateAssetAction(AssetAction)
    case viewTapped
}

// MARK: - Reducer

public struct AvailableBalanceViewReducer: Reducer {
    
    public typealias State = AvailableBalanceViewState
    public typealias Action = AvailableBalanceViewAction

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let balancePublisher: AnyPublisher<FiatValue, Never>
    let availableBalancePublisher: AnyPublisher<FiatValue, Never>
    let feesPublisher: AnyPublisher<FiatValue, Never>
    let transactionIsFeeLessPublisher: AnyPublisher<Bool, Never>
    let onViewTapped: (() -> Void)?

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        balancePublisher: AnyPublisher<FiatValue, Never>,
        availableBalancePublisher: AnyPublisher<FiatValue, Never>,
        feesPublisher: AnyPublisher<FiatValue, Never>,
        transactionIsFeeLessPublisher: AnyPublisher<Bool, Never>,
        onViewTapped: (() -> Void)? = nil
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.balancePublisher = balancePublisher
        self.availableBalancePublisher = availableBalancePublisher
        self.feesPublisher = feesPublisher
        self.transactionIsFeeLessPublisher = transactionIsFeeLessPublisher
        self.onViewTapped = onViewTapped
    }

    static var preview: Self {
        AvailableBalanceViewReducer(
            app: App.preview,
            balancePublisher: .empty(),
            availableBalancePublisher: .empty(),
            feesPublisher: .empty(),
            transactionIsFeeLessPublisher: .empty()
        )
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:

                return .merge(
                    .publisher {
                        balancePublisher
                            .receive(on: mainQueue)
                            .map(AvailableBalanceViewAction.updateBalance)
                    },

                    .publisher {
                        availableBalancePublisher
                            .receive(on: mainQueue)
                            .map(AvailableBalanceViewAction.updateAvailableBalance)
                    },

                    .publisher {
                        feesPublisher
                            .receive(on: mainQueue)
                            .map(AvailableBalanceViewAction.updateFees)
                    },

                    .publisher {
                        app
                            .publisher(for: blockchain.ux.transaction.id, as: String.self)
                            .compactMap(\.value)
                            .compactMap { AssetAction(rawValue: $0) }
                            .map(AvailableBalanceViewAction.updateAssetAction)
                    }
                )

            case .updateAvailableBalance(let fiatValue):
                state.availableBalance = fiatValue
                return .none

            case .updateBalance(let fiatValue):
                state.balance = fiatValue
                return .none

            case .updateAssetAction(let action):
                state.action = action
                return .none

            case .updateFees(let fiatValue):
                state.fees = fiatValue
                return .none

            case .viewTapped:
                return .run { _ in
                    onViewTapped?()
                }
            }
        }
    }
}

public struct AvailableBalanceView: View {

    let store: Store<AvailableBalanceViewState, AvailableBalanceViewAction>

    public init(store: Store<AvailableBalanceViewState, AvailableBalanceViewAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                if let action = viewStore.action {
                    Text("\(LocalizationConstants.availableTo) \(action.name)")
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)

                    if viewStore.isDataPopulated {
                        // Only show the info icon if there is data to show
                        // when the view is tapped. If not the view shouldn't be tappable.
                        Icon
                            .questionFilled
                            .frame(width: 14, height: 14)
                            .accentColor(.semantic.muted)
                            .onTapGesture {
                                viewStore.send(.viewTapped)
                            }
                    }
                }
                Spacer()
                if let availableBalance = viewStore.availableBalance, availableBalance.isPositive {
                    Text("\(availableBalance.displayString)")
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)
                } else if viewStore.isDataPopulated {
                    ProgressView()
                        .frame(width: 14, height: 14)
                }
            }
            .padding([.leading, .trailing], 24.pt)
            .background(BlockchainComponentLibrary.Color.semantic.light)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AvailableBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableBalanceView(
            store: Store(
                initialState: .init(),
                reducer: { AvailableBalanceViewReducer.preview }
            )
        )
    }
}
