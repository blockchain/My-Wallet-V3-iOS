// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureAppUpgradeDomain
import SwiftUI
import ToolKit

public struct AppUpgradeView: View {

    @Environment(\.openURL) private var openURL
    let store: Store<AppUpgradeState, AppUpgradeAction>

    public init(store: Store<AppUpgradeState, AppUpgradeAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: 16) {
                Image(viewStore.state.logo, bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                Image(viewStore.state.badge, bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(viewStore.state.title)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(viewStore.state.subtitle)
                    .padding(.horizontal, 18)
                    .typography(.body1)
                    .foregroundColor(.semantic.title)
                Spacer()
                if viewStore.state.style.isSkippable {
                    MinimalButton(
                        title: AppUpgradeState.Button.skip.title,
                        isOpaque: true,
                        action: {
                            viewStore.send(.skip)
                        }
                    )
                    .frame(width: .infinity)
                    .padding(.horizontal, 16)
                }
                if viewStore.state.cta.isStatus {
                    MinimalButton(
                        title: viewStore.state.cta.title,
                        isOpaque: true,
                        action: {
                            if let url = viewStore.state.cta.url {
                                openURL(url)
                            }
                        }
                    )
                    .frame(width: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                } else {
                    PrimaryButton(
                        title: viewStore.state.cta.title,
                        action: {
                            if let url = viewStore.state.cta.url {
                                openURL(url)
                            }
                        }
                    )
                    .frame(width: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("gradient-background", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
            .background(Color.semantic.background)
        }
    }
}

// MARK: - Previews

struct AppUpgradeView_Previews: PreviewProvider {

    static var previews: some View {
        AppUpgradeView(
            store: .init(
                initialState: AppUpgradeState(style: .unsupportedOS, url: ""),
                reducer: AppUpgradeReducer()
            )
        )
        AppUpgradeView(
            store: .init(
                initialState: AppUpgradeState(style: .maintenance, url: ""),
                reducer: AppUpgradeReducer()
            )
        )
        AppUpgradeView(
            store: .init(
                initialState: AppUpgradeState(style: .appMaintenance, url: ""),
                reducer: AppUpgradeReducer()
            )
        )
        AppUpgradeView(
            store: .init(
                initialState: AppUpgradeState(style: .softUpgrade, url: ""),
                reducer: AppUpgradeReducer()
            )
        )
        AppUpgradeView(
            store: .init(
                initialState: AppUpgradeState(style: .hardUpgrade, url: ""),
                reducer: AppUpgradeReducer()
            )
        )
    }
}
