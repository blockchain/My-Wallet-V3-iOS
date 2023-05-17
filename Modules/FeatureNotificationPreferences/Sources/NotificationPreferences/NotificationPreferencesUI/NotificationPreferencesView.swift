// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureNotificationPreferencesDomain
import FeatureNotificationPreferencesMocks
import Localization
import SwiftUI
import UIComponentsKit

public struct FeatureNotificationPreferencesView: View {
    var store: Store<NotificationPreferencesState, NotificationPreferencesAction>
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewStore: ViewStore<NotificationPreferencesState, NotificationPreferencesAction>

    public init(store: Store<NotificationPreferencesState, NotificationPreferencesAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryNavigationView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    switch viewStore.state.viewState {
                    case .loading:
                        LoadingStateView(title: "")
                    case .data:
                        optionsSection
                        Spacer()
                    case .error:
                        errorSection
                    }
                }
                .background(Color.semantic.background.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .navigationRoute(in: store)
                .trailingNavigationButton(.close) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
        .onDisappear {
            viewStore.send(.onDissapear)
        }
    }
}

extension FeatureNotificationPreferencesView {
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(LocalizationConstants.NotificationPreferences.NotificationScreen.Title.titleString)
                .typography(.title3)
            Text(LocalizationConstants.NotificationPreferences.NotificationScreen.Description.descriptionString)
                .typography(.paragraph1)
                .foregroundColor(Color.WalletSemantic.body)
        }
        .padding(.horizontal, Spacing.padding3)
    }

    var optionsSection: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 10) {
                if case .data(let preferences) = viewStore.state.viewState {
                    ForEach(preferences) { notificationPreference in
                        PrimaryRow(
                            title: notificationPreference.title,
                            subtitle: notificationPreference.subtitle,
                            trailing: { Icon.chevronRight
                                .color(.semantic.muted)
                                .frame(width: 24, height: 24)
                            },
                            action: {
                                viewStore.send(.onPreferenceSelected(notificationPreference))
                                viewStore.send(.route(.navigate(to: .showDetails)))
                            }
                        )
                    }
                }
            }
            .padding(.top, 66)
        }
    }

    var errorSection: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 8, content: {
                Spacer()
                Text(LocalizationConstants.NotificationPreferences.Error.Title.titleString)
                    .multilineTextAlignment(.center)
                    .typography(.title3)
                    .padding(.horizontal, Spacing.padding3)
                    .foregroundColor(Color.WalletSemantic.title)

                Text(LocalizationConstants.NotificationPreferences.Error.Description.descriptionString)
                    .multilineTextAlignment(.center)
                    .typography(.caption1)
                    .padding(.horizontal, Spacing.padding3)
                    .foregroundColor(Color.WalletSemantic.muted)
                Spacer()
                PrimaryButton(title: LocalizationConstants.NotificationPreferences.Error.RetryButton.tryAgainString) {
                    viewStore.send(.onReloadTap)
                }
                .padding(.horizontal, Spacing.padding3)
                .padding(.bottom, Spacing.padding2)

                MinimalButton(title: LocalizationConstants.NotificationPreferences.Error.GoBackButton.goBackString) {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal, Spacing.padding3)
            })
        }
    }
}
