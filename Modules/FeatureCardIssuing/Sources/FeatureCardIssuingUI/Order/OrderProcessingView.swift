// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import Errors
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct OrderProcessingView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                switch viewStore.state.orderProcessingState {
                case .success:
                    success
                case .error(let error):
                    ErrorView(
                        title: error.displayTitle,
                        description: error.displayDescription,
                        retryTitle: error.retryTitle,
                        retryAction: error.retryAction(with: viewStore),
                        cancelAction: {
                            viewStore.send(.close(.cancelled))
                        }
                    )
                default:
                    processing
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder var processing: some View {
        VStack(spacing: Spacing.padding3) {
            ProgressView(value: 0.25)
                .progressViewStyle(.indeterminate)
                .frame(width: 52, height: 52)
            Text(L10n.Processing.Processing.title)
                .typography(.title3)
                .foregroundColor(.WalletSemantic.body)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.padding6)
        }
        .padding(Spacing.padding3)
        .padding(.bottom, Spacing.padding6)
    }

    @ViewBuilder var success: some View {
        VStack(spacing: Spacing.padding3) {
            ZStack(alignment: .topTrailing) {
                Icon
                    .creditcard
                    .color(.WalletSemantic.primary)
                    .frame(width: 60, height: 60)
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                    Icon
                        .checkCircle
                        .color(.WalletSemantic.success)
                        .frame(width: 20, height: 20)
                }
                .padding(.top, -4)
                .padding(.trailing, -8)
            }
            .padding(.top, Spacing.padding6)
            WithViewStore(store) { viewStore in
                VStack(spacing: Spacing.padding1) {
                    Text((viewStore.state.selectedProduct?.type ?? .virtual).successTitle)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                    Text((viewStore.state.selectedProduct?.type ?? .virtual).successCaption)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.padding3)
            }
            Spacer()
            WithViewStore(store) { viewStore in
                PrimaryButton(title: L10n.Processing.Success.goToDashboard) {
                    guard case .success(let card) = viewStore.orderProcessingState else {
                        return
                    }
                    viewStore.send(.close(.created(card)))
                }
            }
        }
        .padding(Spacing.padding3)
    }
}

extension Card.CardType {

    private typealias L10n = LocalizationConstants.CardIssuing.Order.Processing.Success

    fileprivate var successTitle: String {
        switch self {
        case .physical, .shadow:
            return L10n.Physical.title
        case .virtual:
            return L10n.Virtual.title
        }
    }

    fileprivate var successCaption: String {
        switch self {
        case .physical, .shadow:
            return L10n.Physical.caption
        case .virtual:
            return L10n.Virtual.caption
        }
    }
}

#if DEBUG
struct OrderProcessing_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<OrderProcessingView> {
            OrderProcessingView(
                store: Store(
                    initialState: .init(
                        initialKyc: KYC(status: .success, errorFields: nil),
                        selectedProduct: Product(
                            productCode: "42",
                            price: Money(value: "0", symbol: "BTC"),
                            brand: .visa,
                            type: .physical,
                            remainingCards: 1
                        ),
                        orderProcessingState: .success(MockServices.card)
                    ),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

extension Error {

    fileprivate var displayTitle: String {
        guard let error = self as? NabuNetworkError else {
            return LocalizationConstants
                .CardIssuing
                .Errors
                .GenericProcessingError
                .title
        }

        return error.displayTitle
    }

    fileprivate var displayDescription: String {
        guard let error = self as? NabuNetworkError else {
            return LocalizationConstants
                .CardIssuing
                .Errors
                .GenericProcessingError
                .description
        }

        return error.displayDescription
    }

    fileprivate func retryAction(
        with viewStore: ViewStore<CardOrderingState, CardOrderingAction>
    ) -> (() -> Void)? {

        guard let error = self as? NabuNetworkError else {
            return {
                viewStore.send(.createCard)
            }
        }

        switch error.code {
        case .stateNotEligible:
            return {
                viewStore.send(.displayEligibleStateList)
            }
        case .countryNotEligible:
            return {
                viewStore.send(.displayEligibleCountryList)
            }
        default:
            return {
                viewStore.send(.createCard)
            }
        }
    }

    fileprivate var retryTitle: String {

        guard let error = self as? NabuNetworkError else {
            return LocalizationConstants
                .CardIssuing
                .Error
                .retry
        }

        return error.retryTitle
    }
}
