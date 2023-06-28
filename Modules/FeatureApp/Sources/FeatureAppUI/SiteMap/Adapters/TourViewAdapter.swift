// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureAuthenticationUI
import FeatureTourUI
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public struct TourViewAdapter: View {

    @BlockchainApp var app

    private let store: Store<WelcomeState, WelcomeAction>

    @State var manualLoginEnabled: Bool = false

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            OnboardingCarouselView(
                environment: TourEnvironment(
                    createAccountAction: { viewStore.send(.navigate(to: .createWallet)) },
                    restoreAction: { viewStore.send(.navigate(to: .restoreWallet)) },
                    logInAction: { viewStore.send(.navigate(to: .emailLogin)) },
                    manualLoginAction: { viewStore.send(.navigate(to: .manualLogin)) }
                ),
                manualLoginEnabled: manualLoginEnabled
            )
        }
        .navigationRoute(in: store)
        .onReceive(
            app
                .publisher(for: blockchain.app.configuration.manual.login.is.enabled, as: Bool.self)
                .prefix(1)
                .replaceError(with: false)
        ) { isEnabled in
            manualLoginEnabled = isEnabled
        }
    }
}
