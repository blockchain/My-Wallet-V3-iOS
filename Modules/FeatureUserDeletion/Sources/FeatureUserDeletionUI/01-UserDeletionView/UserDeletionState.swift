import ComposableArchitecture
import ComposableNavigation
import FeatureUserDeletionDomain
import SwiftUI

public struct UserDeletionState: Equatable, NavigationState {
    public var route: RouteIntent<UserDeletionRoute>?
    public var confirmViewState: DeletionConfirmState?

    public init(
        confirmViewState: DeletionConfirmState? = DeletionConfirmState(),
        route: RouteIntent<UserDeletionRoute>? = nil
    ) {
        self.confirmViewState = confirmViewState
        self.route = route
    }
}

extension UserDeletionState {
    var externalLinks: ExternalLinks {
        .init()
    }

    struct ExternalLinks {
        var dataRetention: URL {
            URL(string: "https://www.blockchain.com/legal/privacy")!
        }

        var needHelp: URL {
            URL(string: "https://blockchain.zendesk.com/hc/en-us/articles/5159481570076")!
        }
    }
}

public enum UserDeletionRoute: NavigationRoute, Hashable {
    case showConfirmationView

    public func destination(in store: Store<UserDeletionState, UserDeletionAction>) -> some View {
        switch self {
        case .showConfirmationView:
            IfLetStore(
                store.scope(
                    state: \.confirmViewState,
                    action: UserDeletionAction.onConfirmViewChanged
                ),
                then: { store in
                    DeletionConfirmView(store: store)
                }
            )
        }
    }
}
