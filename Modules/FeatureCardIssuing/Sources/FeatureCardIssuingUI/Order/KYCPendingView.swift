// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import Errors
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct KYCPendingView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if let error = viewStore.state.error {
                    ErrorView(
                        title: error.displayTitle,
                        description: error.displayDescription,
                        retryTitle: error.retryTitle,
                        retryAction: {
                            viewStore.send(.submitKyc)
                        },
                        cancelAction: {
                            viewStore.send(.close(.cancelled))
                        }
                    )
                } else if viewStore.state.updatedKyc == nil {
                    processing
                        .onAppear {
                            viewStore.send(.submitKyc)
                        }
                } else {
                    content
                }
            }
            PrimaryNavigationLink(
                destination: ProductSelectionView(store: store),
                isActive: viewStore.binding(
                    get: {
                        $0.initialKyc.status == .unverified && $0.updatedKyc != nil
                    },
                    send: .none
                ),
                label: EmptyView.init
            )
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder var processing: some View {
        VStack(spacing: Spacing.padding3) {
            ProgressView(value: 0.25)
                .progressViewStyle(.indeterminate)
                .frame(width: 52, height: 52)
            Text(L10n.KycPending.Pending.title)
                .typography(.title3)
                .foregroundColor(.WalletSemantic.body)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.padding6)
        }
        .padding(Spacing.padding3)
        .padding(.bottom, Spacing.padding6)
    }

    @ViewBuilder var content: some View {
        IfLetStore(
            store.scope(state: \.updatedKyc),
            then: { store in
                WithViewStore(store) { viewStore in
                    VStack(spacing: Spacing.padding3) {
                        ZStack(alignment: .bottomTrailing) {
                            Icon
                                .identification
                                .circle()
                                .color(.WalletSemantic.muted)
                                .frame(width: 60, height: 60)
                            ZStack {
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                viewStore.state
                                    .icon
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.top, -4)
                            .padding(.trailing, -8)
                        }
                        .padding(.top, Spacing.padding6)
                        VStack(spacing: Spacing.padding1) {
                            Text(viewStore.state.title)
                                .typography(.title3)
                                .multilineTextAlignment(.center)
                            Text(viewStore.state.caption)
                                .typography(.paragraph1)
                                .foregroundColor(.WalletSemantic.body)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, Spacing.padding3)
                        Spacer()
                        WithViewStore(store) { viewStore in
                            PrimaryButton(title: viewStore.state.button) {
                                viewStore.send(.close(.kyc))
                            }
                        }
                    }
                    .padding(Spacing.padding3)
                }
            },
            else: {
                EmptyView()
            }
        )
    }
}

extension KYC {

    fileprivate typealias L10n = LocalizationConstants.CardIssuing.Order.KycPending

    fileprivate var icon: Icon {
        switch status {
        case .success:
            return Icon
                .checkCircle
                .color(.WalletSemantic.success)
        case .failure:
            return Icon
                .alert
                .color(.WalletSemantic.warning)
        case .unverified, .pending:
            return Icon
                .pending
                .color(.semantic.muted)
        }
    }

    fileprivate var title: String {
        switch status {
        case .success:
            return L10n.Success.title
        case .failure:
            return L10n.Failed.title
        case .unverified, .pending:
            return L10n.Pending.title
        }
    }

    fileprivate var caption: String {
        switch status {
        case .success:
            return L10n.Success.caption
        case .failure:
            return L10n.Failed.caption
        case .unverified, .pending:
            return L10n.Pending.caption
        }
    }

    fileprivate var button: String {
        switch status {
        case .success:
            return L10n.Success.next
        case .failure:
            return L10n.Failed.next
        case .unverified, .pending:
            return L10n.Pending.next
        }
    }
}

#if DEBUG
struct KYCPending_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<KYCPendingView> {
            KYCPendingView(
                store: Store(
                    initialState: .init(
                        initialKyc: KYC(status: .pending, errorFields: nil),
                        updatedKyc: KYC(status: .failure, errorFields: nil)
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
