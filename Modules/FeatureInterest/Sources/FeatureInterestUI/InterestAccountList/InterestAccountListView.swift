// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import FeatureInterestDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

protocol InterestAccountListViewDelegate: AnyObject {
    func didTapVerifyMyIdentity()
    func didTapBuyCrypto(_ cryptoCurrency: CryptoCurrency)
}

struct InterestAccountListView: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview

    weak var delegate: InterestAccountListViewDelegate?

    let store: Store<InterestAccountListState, InterestAccountListAction>
    let embeddedInNavigationView: Bool

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.isLoading {
                    LoadingStateView(title: "")
                        .onAppear {
                            if let cryptoCurrency = viewStore.buyCryptoCurrency {
                                delegate?.didTapBuyCrypto(cryptoCurrency)
                            }
                        }
                } else if viewStore.interestAccountFetchFailed {
                    InterestAccountListErrorView(action: {
                        viewStore.send(.setupInterestAccountListScreen)
                    })
                } else if embeddedInNavigationView {
                    PrimaryNavigationView {
                        list(in: viewStore)
                            .whiteNavigationBarStyle()
                            .navigationTitle(LocalizationId.title)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                } else {
                    list(in: viewStore)
                }
            }
            .onAppear {
                viewStore.send(.setupInterestAccountListScreen)
            }
        }
    }

    func list(in viewStore: ViewStore<InterestAccountListState, InterestAccountListAction>) -> some View {
        List {
            if !viewStore.isKYCVerified {
                InterestIdentityVerificationView {
                    delegate?.didTapVerifyMyIdentity()
                }
                .listRowInsets(EdgeInsets())
            }
            ForEachStore(
                store.scope(
                    state: \.interestAccountDetails,
                    action: InterestAccountListAction.interestAccountButtonTapped
                )
            ) { cellStore in
                InterestAccountListItem(store: cellStore)
            }
        }
        .hideScrollContentBackground()
        .listStyle(PlainListStyle())
        .navigationRoute(in: store)
    }
}

struct InterestAccountListView_Previews: PreviewProvider {

    static var testCurrencyPairs = [
        InterestAccountDetails(
            ineligibilityReason: .eligible,
            currency: .crypto(.bitcoin),
            balance: MoneyValue.create(major: "12.0", currency: .crypto(.bitcoin))!,
            interestEarned: MoneyValue.create(major: "12.0", currency: .crypto(.bitcoin))!,
            rate: 8.0
        )
    ]

    static var previews: some View {
        InterestAccountListView(
            store: .init(
                initialState: InterestAccountListState(
                    interestAccountDetails: .init(uniqueElements: testCurrencyPairs),
                    loadingStatus: .loaded
                ),
                reducer: interestAccountListReducer,
                environment: .init(
                    fiatCurrencyService: NoOpFiatCurrencyPublisher(),
                    accountOverviewRepository: NoOpInterestAccountOverviewRepository(),
                    accountBalanceRepository: NoOpInterestAccountBalanceRepository(),
                    accountRepository: NoOpBlockchainAccountRepository(),
                    priceService: NoOpPriceService(),
                    blockchainAccountRepository: NoOpBlockchainAccountRepository(),
                    kycVerificationService: NoOpKYCVerificationService(),
                    transactionRouterAPI: NoOpTransactionsRouter(),
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    mainQueue: .main
                )
            ),
            embeddedInNavigationView: true
        )
    }
}
