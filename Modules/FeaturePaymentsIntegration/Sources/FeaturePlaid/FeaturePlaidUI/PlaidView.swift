// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ErrorsUI
import Localization
import SwiftUI

public struct PlaidView: View {
    let store: Store<PlaidState, PlaidAction>
    @ObservedObject var viewStore: ViewStore<PlaidState, PlaidAction>

    public init(store: Store<PlaidState, PlaidAction>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        WithViewStore(store.scope(state: \.uxError, action: { $0 }), observe: { $0 }) { viewStore in
            switch viewStore.state {
            case .some(let uxError):
                PrimaryNavigationView {
                    ErrorView(
                        ux: uxError,
                        dismiss: {
                            viewStore.send(.finished(success: false))
                        }
                    )
                }
            default:
                EmptyView()
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}
