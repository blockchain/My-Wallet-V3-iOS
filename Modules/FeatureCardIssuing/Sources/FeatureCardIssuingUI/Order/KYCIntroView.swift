// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import Errors
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct KYCIntroView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order.KycPending

    private let store: Store<CardOrderingState, CardOrderingAction>
    @State private var isNextScreenVisible = false

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        IfLetStore(
            store.scope(state: \.initialKyc.errorFields),
            then: { store in
                WithViewStore(store) { viewStore in
                    if viewStore.state.isEmpty {
                        defaultContent
                    } else {
                        fields(viewStore.state)
                    }
                }
            },
            else: {
                defaultContent
            }
        )
    }

    @ViewBuilder var defaultContent: some View {
        WithViewStore(store.scope(state: \.initialKyc)) { viewStore in
            switch viewStore.state.status {
            case .success:
                success
            case .failure:
                error
            case .pending, .unverified:
                pending
            }
        }
    }

    @ViewBuilder func fields(_ fields: [KYC.Field]) -> some View {
        VStack(spacing: Spacing.padding3) {
            ZStack(alignment: .bottomTrailing) {
                Icon
                    .identification
                    .color(.semantic.body)
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 60, height: 60)
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                    Icon
                        .alert
                        .color(.semantic.warning)
                        .frame(width: 24, height: 24)
                }
                .padding(.bottom, -4)
                .padding(.trailing, -8)
            }
            .padding(.top, Spacing.padding6)
            VStack(spacing: Spacing.padding1) {
                Text(L10n.Error.title)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                Text(L10n.Error.description)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.padding3)
            VStack(spacing: Spacing.padding2) {
                ForEach(fields) { field in
                    HStack(spacing: Spacing.padding2) {
                        Icon
                            .alert
                            .color(.semantic.warning)
                            .frame(width: 24, height: 24)
                        switch field {
                        case .ssn:
                            Text(L10n.Error.ssn)
                                .typography(.paragraph2)
                        case .residentialAddress:
                            Text(L10n.Error.address)
                                .typography(.paragraph2)
                        }
                        Spacer()
                    }
                    .padding(Spacing.padding2)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.semantic.light)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.semantic.medium, lineWidth: 1)
                    )
                }
            }
            Spacer()
            PrimaryButton(title: L10n.Failed.next) {
                isNextScreenVisible = true
            }
            PrimaryNavigationLink(
                destination: nextView(fields),
                isActive: $isNextScreenVisible,
                label: EmptyView.init
            )
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder private func nextView(_ fields: [KYC.Field]) -> some View {
        if fields.contains(.residentialAddress) {
            ResidentialAddressConfirmationView(store: store)
        } else {
            SSNInputView(store: store)
        }
    }

    @ViewBuilder var pending: some View {
        VStack(spacing: Spacing.padding3) {
            ZStack(alignment: .bottomTrailing) {
                Icon
                    .identification
                    .color(.semantic.body)
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 60, height: 60)
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                    Icon
                        .pending
                        .color(.WalletSemantic.muted)
                        .frame(width: 24, height: 24)
                }
                .padding(.bottom, -4)
                .padding(.trailing, -8)
            }
            .padding(.top, Spacing.padding6)
            Text(L10n.Pending.title)
                .typography(.title3)
                .multilineTextAlignment(.center)
            Text(L10n.Pending.caption)
                .typography(.body1)
                .foregroundColor(.WalletSemantic.body)
                .multilineTextAlignment(.center)
            Spacer()
            WithViewStore(store) { viewStore in
                PrimaryButton(title: L10n.Pending.next) {
                    viewStore.send(.close(.cancelled))
                }
            }
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder var error: some View {
        VStack(spacing: Spacing.padding3) {
            ZStack(alignment: .bottomTrailing) {
                Icon
                    .identification
                    .color(.semantic.body)
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 60, height: 60)
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                    Icon
                        .closeCircle
                        .color(.semantic.error)
                        .frame(width: 24, height: 24)
                }
                .padding(.bottom, -4)
                .padding(.trailing, -8)
            }
            .padding(.top, Spacing.padding6)
            VStack(spacing: Spacing.padding1) {
                Text(L10n.Failed.title)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                Text(L10n.Failed.caption)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.padding3)
            Spacer()
            WithViewStore(store) { viewStore in
                PrimaryButton(title: LocalizationConstants.CardIssuing.Manage.Activity.Button.help) {
                    viewStore.send(.showSupportFlow)
                }
            }
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder var success: some View {
        VStack(spacing: Spacing.padding3) {
            ZStack(alignment: .bottomTrailing) {
                Icon
                    .identification
                    .color(.semantic.body)
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 60, height: 60)
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                    Icon
                        .checkCircle
                        .color(.WalletSemantic.success)
                        .frame(width: 24, height: 24)
                }
                .padding(.bottom, -4)
                .padding(.trailing, -8)
            }
            .padding(.top, Spacing.padding6)
            VStack(spacing: Spacing.padding1) {
                Text(L10n.Success.title)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                Text(L10n.Success.caption)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.padding3)
            Spacer()
            WithViewStore(store) { viewStore in
                PrimaryButton(title: L10n.Success.next) {
                    viewStore.send(.close(.cancelled))
                }
            }
        }
        .padding(Spacing.padding3)
    }
}

#if DEBUG
struct KYCIntro_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<KYCIntroView> {
            KYCIntroView(
                store: Store(
                    initialState: .init(
                        initialKyc: KYC(status: .failure, errorFields: [.ssn, .residentialAddress]),
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
