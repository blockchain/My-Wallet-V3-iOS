// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public enum WelcomeRoute: NavigationRoute {
    case createWallet
    case emailLogin
    case restoreWallet
    case manualLogin

    @ViewBuilder
    public func destination(
        in store: Store<WelcomeState, WelcomeAction>
    ) -> some View {
        switch self {
        case .createWallet:
            IfLetStore(
                store.scope(
                    state: \.createWalletState,
                    action: WelcomeAction.createWallet
                ),
                then: CreateAccountStepOneView.init(store:)
            )
        case .emailLogin:
            IfLetStore(
                store.scope(
                    state: \.emailLoginState,
                    action: WelcomeAction.emailLogin
                ),
                then: EmailLoginView.init(store:)
            )
        case .restoreWallet:
            IfLetStore(
                store.scope(
                    state: \.restoreWalletState,
                    action: WelcomeAction.restoreWallet
                ),
                then: SeedPhraseView.init(store:)
            )
        case .manualLogin:
            IfLetStore(
                store.scope(
                    state: \.manualCredentialsState,
                    action: WelcomeAction.manualPairing
                ),
                then: { store in
                    CredentialsView(
                        context: .manualPairing,
                        store: store
                    )
                }
            )
        }
    }
}
