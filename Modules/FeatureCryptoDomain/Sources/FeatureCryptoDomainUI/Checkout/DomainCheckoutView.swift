// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

struct DomainCheckoutView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.DomainCheckout
    private typealias Accessibility = AccessibilityIdentifiers.DomainCheckout

    private let store: Store<DomainCheckoutState, DomainCheckoutAction>

    init(store: Store<DomainCheckoutState, DomainCheckoutAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            checkoutView
                .primaryNavigation(title: LocalizedString.navigationTitle)
                .navigationRoute(in: store)
                .bottomSheet(isPresented: viewStore.binding(\.$isRemoveBottomSheetShown)) {
                    createRemoveBottomSheet(
                        domain: viewStore.binding(\.$removeCandidate),
                        removeButtonTapped: {
                            viewStore.send(.removeDomain(viewStore.removeCandidate), animation: .linear)
                        }
                    )
                }
        }
    }

    @ViewBuilder
    private var checkoutView: some View {
        WithViewStore(store) { viewStore in
            if !viewStore.selectedDomains.isEmpty {
                VStack(spacing: Spacing.padding2) {
                    selectedDomains
                        .padding(.top, Spacing.padding3)
                    Spacer()
                    termsRow
                    PrimaryButton(
                        title: LocalizedString.button,
                        isLoading: viewStore.isLoading
                    ) {
                        viewStore.send(.claimDomain)
                    }
                    .disabled(viewStore.selectedDomains.isEmpty || viewStore.termsSwitchIsOn == false)
                    .accessibility(identifier: Accessibility.ctaButton)
                }
                .padding([.leading, .trailing, .bottom], Spacing.padding3)
            } else {
                VStack(spacing: Spacing.padding3) {
                    Spacer()
                    Icon.cart
                        .color(.semantic.primary)
                        .frame(width: 54, height: 54)
                        .accessibility(identifier: Accessibility.emptyStateIcon)
                    Text(LocalizedString.emptyTitle)
                        .typography(.title3)
                        .accessibility(identifier: Accessibility.emptyStateTitle)
                    Text(LocalizedString.emptyInstruction)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.overlay)
                        .accessibility(identifier: Accessibility.emptyStateDescription)
                    Spacer()
                    PrimaryButton(title: LocalizedString.browseButton) {
                        viewStore.send(.returnToBrowseDomains)
                    }
                    .accessibility(identifier: Accessibility.browseButton)
                }
                .padding([.leading, .trailing, .bottom], Spacing.padding3)
            }
        }
    }

    private var selectedDomains: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack {
                    ForEach(viewStore.selectedDomains, id: \.domainName) { domain in
                        PrimaryRow(
                            title: domain.domainName,
                            subtitle: domain.domainType.statusLabel,
                            trailing: {
                                Button(
                                    action: {
                                        viewStore.send(.set(\.$removeCandidate, domain))
                                    },
                                    label: {
                                        Icon.delete
                                            .color(.semantic.muted)
                                            .frame(width: 24, height: 24)
                                    }
                                )
                            }
                        ).overlay(
                            RoundedRectangle(cornerRadius: 8.0)
                                .strokeBorder(Color.semantic.medium)
                        )
                    }
                }
                .accessibility(identifier: Accessibility.selectedDomainList)
            }
        }
    }

    private var termsRow: some View {
        WithViewStore(store) { viewStore in
            HStack(alignment: .center, spacing: Spacing.padding1) {
                PrimarySwitch(
                    accessibilityLabel: Accessibility.termsSwitch,
                    isOn: viewStore.binding(\.$termsSwitchIsOn)
                )
                Text(
                    String(
                        format: LocalizedString.terms,
                        NonLocalizedConstants.defiWalletTitle,
                        viewStore.selectedDomains.first?.domainName ?? ""
                    )
                )
                .typography(.micro)
                .accessibilityIdentifier(Accessibility.termsText)
            }
        }
    }

    private func createRemoveBottomSheet(
        domain: Binding<SearchDomainResult?>,
        removeButtonTapped: @escaping (() -> Void)
    ) -> some View {
        WithViewStore(store) { viewStore in
            RemoveDomainActionView(
                domain: domain,
                isShown: viewStore.binding(\.$isRemoveBottomSheetShown),
                removeButtonTapped: removeButtonTapped
            )
        }
    }
}

#if DEBUG

@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainMock

struct DomainCheckView_Previews: PreviewProvider {
    static var previews: some View {
        DomainCheckoutView(
            store: .init(
                initialState: .init(),
                reducer: domainCheckoutReducer,
                environment: DomainCheckoutEnvironment(
                    mainQueue: .main,
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    orderDomainRepository: OrderDomainRepository(
                        apiClient: OrderDomainClient.mock
                    ),
                    userInfoProvider: { .empty() }
                )
            )
        )
    }
}
#endif
