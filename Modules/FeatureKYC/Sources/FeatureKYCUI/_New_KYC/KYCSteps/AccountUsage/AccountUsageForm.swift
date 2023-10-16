// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import Errors
import FeatureFormDomain
import FeatureFormUI
import Localization
import SwiftUI
import ToolKit

private typealias L10n = LocalizationConstants.NewKYC.Steps.AccountUsage

@MainActor
struct AccountUsageForm: View {

    let store: Store<AccountUsage.Form.State, AccountUsage.Form.Action>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.form.isEmpty {
                emptyFormView(viewStore)
            } else {
                filledFormView(viewStore)
            }
        }
    }

    @ViewBuilder
    private func emptyFormView(
        _ viewStore: ViewStore<AccountUsage.Form.State, AccountUsage.Form.Action>
    ) -> some View {
        VStack(spacing: Spacing.padding3) {
            VStack(spacing: Spacing.textSpacing) {
                Text(L10n.stepNotNeededTitle)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)

                Text(L10n.stepNotNeededMessage)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
            }
            .multilineTextAlignment(.center)

            BlockchainComponentLibrary.PrimaryButton(
                title: L10n.stepNotNeededContinueCTA
            ) {
                viewStore.send(.onComplete)
            }
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder
    private func filledFormView(
        _ viewStore: ViewStore<AccountUsage.Form.State, AccountUsage.Form.Action>
    ) -> some View {
        PrimaryForm(
            form: viewStore.$form,
            submitActionTitle: L10n.submitActionTitle,
            submitActionLoading: viewStore.submissionState == .loading,
            submitAction: {
                viewStore.send(.submit)
            }
        )
        .background(Color.semantic.light.ignoresSafeArea())
        .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
    }
}

struct AccountUsageForm_Previews: PreviewProvider {

    static var previews: some View {
        AccountUsageForm(
            store: Store(
                initialState: AccountUsage.Form.State(
                    form: FeatureFormDomain.Form(nodes: AccountUsage.previewQuestions)
                ),
                reducer: {
                    AccountUsage.Form.FormReducer(
                        submitForm: { _ in .failure(.unknown) },
                        mainQueue: .main
                    )
                }
            )
        )
        .previewDisplayName("Valid Form")

        AccountUsageForm(
            store: Store(
                initialState: AccountUsage.Form.State(
                    form: Form(nodes: [])
                ),
                reducer: {
                    AccountUsage.Form.FormReducer(
                        submitForm: { _ in .empty() },
                        mainQueue: .main
                    )
                }
            )
        )
        .previewDisplayName("Empty Form (KYC step to be skipped)")
    }
}
