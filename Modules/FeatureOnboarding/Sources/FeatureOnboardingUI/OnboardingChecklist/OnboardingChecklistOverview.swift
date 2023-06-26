// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import ToolKit

public struct OnboardingChecklistOverview: View {

    private let store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>
    @ObservedObject var viewStore: ViewStore<OnboardingChecklist.State, OnboardingChecklist.Action>

    public init(store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        content
            .onAppear {
                viewStore.send(.startObservingUserState)
            }
            .onDisappear {
                viewStore.send(.stopObservingUserState)
            }
    }

    @ViewBuilder var content: some View {
        if viewStore.isSynchronised {
            OnboardingChecklistNUXOverview(store)
        } else {
            ProgressView()
        }
    }
}

public struct OnboardingChecklistNUXOverview: View {

    private let store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>
    @ObservedObject var viewStore: ViewStore<OnboardingChecklist.State, OnboardingChecklist.Action>

    public init(_ store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>) {
        self.store = store
        _viewStore = .init(initialValue: ViewStore(store))
    }

    public var body: some View {
        HStack(spacing: Spacing.padding2) {
            CountedProgressView(
                completedItemsCount: viewStore.completedItems.count,
                totalItemsCount: viewStore.items.count
            )

            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(LocalizationConstants.Onboarding.ChecklistOverview.title)
                    .typography(.caption1)
                    .foregroundColor(.semantic.body)

                Text(LocalizationConstants.Onboarding.ChecklistOverview.subtitle)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }

            Spacer()

            Icon.chevronRight
                .color(.semantic.primary)
                .frame(width: 24, height: 24)
        }
        // pad content
        .padding(Spacing.padding2)
        // round rectable background with border
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(Color.semantic.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .stroke(Color.semantic.primary)
        )
        // actions
        .onTapGesture {
            viewStore.send(.presentFullScreenChecklist)
        }
        .navigationRoute(in: store)
    }
}

// MARK: SwiftUI Previews

#if DEBUG

struct SwiftUIView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingChecklistOverview(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .empty(),
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
