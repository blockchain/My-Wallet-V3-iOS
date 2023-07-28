// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import MoneyKit
import PlatformKit
import SwiftUI
import UIComponentsKit

struct TargetAccountAuxiliaryViewState: Equatable {
    let asset: CryptoCurrency
    let title: String
    let color: Color
    let enabled: Bool
}

enum TargetAccountAuxiliaryViewAction: Equatable {
    case tap
}

struct TargetAccountAuxiliaryViewEnvironment {
    let onTap: () -> Void
}

let targetAccountAuxiliaryViewReducer = Reducer<
    TargetAccountAuxiliaryViewState,
    TargetAccountAuxiliaryViewAction,
    TargetAccountAuxiliaryViewEnvironment
> { _, action, environment in
    switch action {
    case .tap:
        environment.onTap()
    }
    return .none
}

struct TargetAccountAuxiliaryView: View {

    let store: Store<TargetAccountAuxiliaryViewState, TargetAccountAuxiliaryViewAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: {
                    viewStore.send(.tap)
                },
                label: {
                    HStack(
                        alignment: .center,
                        spacing: Spacing.padding2
                    ) {
                        HStack(spacing: -6) {
                            viewStore.asset
                                .logo(size: 32.pt, showNetworkLogo: false)

                            Icon.plus.circle()
                                .color(viewStore.color)
                                .frame(width: 24.pt)
                        }

                        Text(viewStore.title)
                            .textStyle(.heading)
                            .multilineTextAlignment(.leading)

                        if viewStore.enabled {
                            Spacer()
                            Icon.chevronDown
                                .color(.semantic.dark)
                                .frame(width: 24.pt)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding()
                }
            )
            .disabled(!viewStore.enabled)
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

extension TargetAccountAuxiliaryView {

    init(asset: CryptoCurrency, action: @escaping () -> Void) {
        self.init(
            store: .init(
                initialState: TargetAccountAuxiliaryViewState(
                    asset: asset,
                    title: asset.name,
                    color: asset.brandColor,
                    enabled: true
                ),
                reducer: targetAccountAuxiliaryViewReducer,
                environment: TargetAccountAuxiliaryViewEnvironment(
                    onTap: action
                )
            )
        )
    }
}

#if DEBUG
struct TargetAccountAuxiliaryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            TargetAccountAuxiliaryView(
                asset: .bitcoin,
                action: {}
            )
            Spacer()
        }
    }
}
#endif
