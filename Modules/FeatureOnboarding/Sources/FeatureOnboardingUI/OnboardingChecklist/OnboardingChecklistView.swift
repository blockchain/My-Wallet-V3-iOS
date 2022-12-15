// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public struct OnboardingChecklistView: View {

    private let store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>
    @ObservedObject private var viewStore: ViewStore<OnboardingChecklist.State, OnboardingChecklist.Action>

    public init(store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
            VStack {

                closeButton
                    .padding(.top, 19)
                    .padding(.horizontal, 17)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity)

                ScrollView {
                    VStack(spacing: 32) {
                        CountedProgressView(
                            size: .large,
                            completedItemsCount: viewStore.completedItems.count,
                            totalItemsCount: viewStore.items.count,
                            backgroundColor: .semantic.medium
                        )

                        VStack(spacing: Spacing.padding1) {
                            Text(LocalizationConstants.Onboarding.Checklist.screenTitle)
                                .typography(.title3)
                                .foregroundColor(Color.textTitle)
                            Text(LocalizationConstants.Onboarding.Checklist.screenSubtitle)
                                .typography(.body1)
                                .foregroundColor(Color.textBody)
                        }

                        VStack(spacing: Spacing.padding3) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(viewStore.items.indices, id: \.self) { index in
                                    let item = viewStore.items[index]
                                    let completed = viewStore.completedItems.contains(item)
                                    let pending = viewStore.pendingItems.contains(item)
                                    if index != 0 {
                                        DSAPrimaryDivider()
                                    }
                                    OnboardingChecklistRow(
                                        item: item,
                                        status: rowStatusForState(completed: completed, pending: pending)
                                    )
                                    .onTapGesture {
                                        if !completed {
                                            viewStore.send(
                                                .didSelectItem(item.id, .item)
                                            )
                                        }
                                    }
                                }
                            }
                            .background(Color.semantic.dsaContentBackground)
                            .cornerRadius(16, corners: .allCorners)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.padding1)
                                    .stroke(Color.semantic.light, lineWidth: 1)
                            )

                            Spacer()

                            if let item = viewStore.firstIncompleteItem {
                                Button(item.title) {
                                    viewStore.send(
                                        .didSelectItem(item.id, .callToActionButton)
                                    )
                                }
                                .buttonStyle(
                                    OnboardingChecklistButtonStyle(item: item)
                                )
                            }
                        }
                    }
                    .padding(.top, Spacing.padding2)
                    .padding(.horizontal, Spacing.padding2)
                    .padding(.bottom, Spacing.padding6)
                    .frame(maxWidth: .infinity)
                }
                .onAppear {
                    viewStore.send(.startObservingUserState)
                }
            }
            .background(Color.semantic.dsaBackground.ignoresSafeArea(edges: .bottom))
    }

    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    viewStore.send(.dismissFullScreenChecklist)
                } label: {
                    Icon.closeCirclev3
                        .frame(width: 24, height: 24)
                }
            }
        }
    }

    private func rowStatusForState(completed: Bool, pending: Bool) -> OnboardingChecklistRow.Status {
        guard completed else {
            guard pending else {
                return .incomplete
            }
            return .pending
        }
        return .complete
    }
}

struct OnboardingChecklistButtonStyle: ButtonStyle {

    let item: OnboardingChecklist.Item

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration
                .label
                .typography(.body2)
        }
        .accentColor(.white)
        .foregroundColor(.white)
        .padding(.vertical, Spacing.padding1)
        .padding(.horizontal, Spacing.padding2)
        .frame(maxWidth: .infinity, minHeight: ButtonSize.Standard.height)
        .background(
            RoundedRectangle(cornerRadius: ButtonSize.Standard.cornerRadius)
                .fill(configuration.isPressed ? item.backgroundColor : item.accentColor)
        )
        .contentShape(Rectangle())
    }
}

// MARK: SwiftUI Preview

#if DEBUG

struct OnboardingChecklistView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .notVerified,
                            hasLinkedPaymentMethods: false,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .verificationPending,
                            hasLinkedPaymentMethods: false,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .verified,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .verified,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: true
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )
    }
}

#endif
