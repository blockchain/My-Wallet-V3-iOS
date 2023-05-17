// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureInterestDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct InterestAccountDetailsView: View {

    private typealias LocalizationIds = LocalizationConstants.Interest.Screen.AccountDetails
    private let store: Store<InterestAccountDetailsState, InterestAccountDetailsAction>

    @Environment(\.presentationMode) private var presentationMode

    init(store: Store<InterestAccountDetailsState, InterestAccountDetailsAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isLoading {
                LoadingStateView(title: "")
                    .onAppear {
                        viewStore.send(.loadInterestAccountBalanceInfo)
                    }
            } else {
                PrimaryNavigationView {
                    ActionableView(
                        buttons: viewStore
                            .supportedActions
                            .map { action in
                                switch action {
                                case .interestTransfer:
                                    return .init(
                                        title: LocalizationIds.add + " \(viewStore.currency.displayCode)",
                                        action: {
                                            viewStore.send(
                                                .interestTransferTapped(viewStore.interestAccountOverview.currency)
                                            )
                                        },
                                        style: .primary
                                    )
                                case .interestWithdraw:
                                    return .init(
                                        title: LocalizationIds.withdraw + " \(viewStore.currency.displayCode)",
                                        action: {
                                            viewStore.send(
                                                .interestWithdrawTapped(viewStore.interestAccountOverview.currency)
                                            )
                                        },
                                        style: .secondary
                                    )
                                default:
                                    unimplemented("This action type is not supported in this view")
                                }
                            },
                        content: {
                            List {
                                if let balance = viewStore.interestAccountBalanceSummary {
                                    VStack {
                                        HStack {
                                            badgeImageViewWithViewModel(balance.badgeImageViewModel)
                                                .frame(width: 32, height: 32)
                                            VStack(spacing: 4.0) {
                                                HStack {
                                                    Text(LocalizationIds.rewardsAccount)
                                                        .textStyle(.heading)
                                                    Spacer()
                                                    Text(balance.fiatBalance)
                                                        .textStyle(.heading)
                                                }
                                                HStack {
                                                    Text(balance.currency.name)
                                                        .textStyle(.subheading)
                                                    Spacer()
                                                    Text(balance.cryptoBalance)
                                                        .textStyle(.subheading)
                                                }
                                            }
                                        }
                                        .padding(
                                            .init(
                                                top: 8.0,
                                                leading: 0.0,
                                                bottom: 8.0,
                                                trailing: 0.0
                                            )
                                        )
                                    }
                                }
                                ForEachStore(
                                    store.scope(
                                        state: \.interestAccountRowItems,
                                        action: InterestAccountDetailsAction.interestAccountDescriptorTapped(id:action:)
                                    )
                                ) { cellStore in
                                    InterestAccountDetailsRowItemView(store: cellStore)
                                }
                            }
                            .hideScrollContentBackground()
                        }
                    )
                    .trailingNavigationButton(.close) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .whiteNavigationBarStyle()
                    .navigationTitle(LocalizationIds.rewardsSummary)
                    .navigationBarTitleDisplayMode(.inline)
                    .onDisappear {
                        if let actionSelection = viewStore.interestAccountActionSelection {
                            switch actionSelection.action {
                            case .interestWithdraw:
                                viewStore.send(
                                    .loadCryptoInterestAccount(
                                        isTransfer: false,
                                        actionSelection.currency
                                    )
                                )
                            case .interestTransfer:
                                viewStore.send(
                                    .loadCryptoInterestAccount(
                                        isTransfer: true,
                                        actionSelection.currency
                                    )
                                )
                            default:
                                unimplemented()
                            }
                        }
                    }
                }
            }
        }
    }

    private func badgeImageViewWithViewModel(_ viewModel: BadgeImageViewModel) -> some View {
        BadgeImageViewRepresentable(
            viewModel: viewModel,
            size: 32
        )
    }
}

struct InterestAccountDetailsView_Previews: PreviewProvider {

    static let state: InterestAccountDetailsState = .init(
        interestAccountOverview: .init(
            interestAccountEligibility: .init(
                currencyType: .crypto(.bitcoin),
                isEligible: true,
                ineligibilityReason: .eligible
            ),
            interestAccountRate: .init(currencyCode: "BTC", rate: 4.9),
            interestAccountLimits: .init(
                interestLockupDuration: 4.0,
                cryptoCurrency: .bitcoin,
                nextInterestPayment: Date(),
                minDepositAmount: .zero(currency: .USD),
                maxWithdrawalAmount: .zero(currency: .USD)
            ),
            balanceDetails: .init(
                balance: "10000000000",
                pendingInterest: "1000",
                totalInterest: "5000",
                pendingWithdrawal: "5000",
                pendingDeposit: "5000",
                code: "BTC"
            )
        )
    )

    static var previews: some View {
        InterestAccountDetailsView(
            store: .init(
                initialState: state,
                reducer: interestAccountDetailsReducer,
                environment: .default
            )
        )
    }
}
