// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import Errors
import FeatureFormDomain
import Localization
import SwiftUI
import ToolKit

private typealias L10n = LocalizationConstants.NewKYC.Steps.AccountUsage

struct AccountUsageView: View {

    let store: Store<AccountUsage.State, AccountUsage.Action>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LoadingView(
                store: store,
                success: { successStore in
                    AccountUsageForm(
                        store: successStore.scope(
                            state: { $0 },
                            action: AccountUsage.Action.form
                        )
                    )
                },
                idle: {
                    // If we use an `EmptyView`, `onAppear` isn't called.
                    // A color does the job, instead.
                    Color.semantic.light
                        .onAppear {
                            viewStore.send(.loadForm)
                        }
                }
            )
        }
        .primaryNavigation(title: L10n.title)
    }
}

struct AccountUsageView_Previews: PreviewProvider {

    static var previews: some View {
        AccountUsageView(
            store: Store(
                initialState: AccountUsage.State.loading,
                reducer: { AccountUsage.AccountUsageReducer.preview }
            )
        )
        .previewDisplayName("Account Usage View - loading")

        AccountUsageView(
            store: Store(
                initialState: AccountUsage.State.success(
                    AccountUsage.Form.State(
                        form: FeatureFormDomain.Form(nodes: AccountUsage.previewQuestions)
                    )
                ),
                reducer: { AccountUsage.AccountUsageReducer.preview }
            )
        )
        .previewDisplayName("Account Usage View - success")

        AccountUsageView(
            store: Store(
                initialState: AccountUsage.State.failure(
                    FailureState(
                        title: "Error",
                        message: "Something went wrong",
                        buttons: [
                            .primary(
                                title: "Retry",
                                action: .loadForm
                            ),
                            .destructive(
                                title: "Close",
                                action: .dismiss
                            )
                        ]
                    )
                ),
                reducer: { AccountUsage.AccountUsageReducer.preview }
            )
        )
        .previewDisplayName("Account Usage View - failure")
    }
}
