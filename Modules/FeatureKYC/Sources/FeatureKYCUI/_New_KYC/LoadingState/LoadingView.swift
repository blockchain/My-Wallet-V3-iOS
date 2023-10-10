// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI

struct LoadingView<
    Success: Equatable,
    Action: Equatable,
    SuccessContent: View,
    IdleContent: View
>: View {

    typealias State = LoadingState<Success, FailureState<Action>>

    private var store: Store<State, Action>
    private let success: (Store<Success, Action>) -> SuccessContent
    private let idle: () -> IdleContent

    init(
        store: Store<State, Action>,
        @ViewBuilder success: @escaping (Store<Success, Action>) -> SuccessContent,
        @ViewBuilder idle: @escaping () -> IdleContent
    ) {
        self.store = store
        self.success = success
        self.idle = idle
    }

    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .success:
                CaseLet<State, Action, Success, Action, SuccessContent>(
                    state: /State.success,
                    then: success
                )
            case .failure:
                CaseLet<State, Action, FailureState<Action>, Action, LoadingFailureView>(
                    state: /State.failure,
                    then: LoadingFailureView.init(store:)
                )
            default:
                WithViewStore(store, observe: { $0 }) { viewStore in
                    contentView(viewStore)
                }
            }
        }
    }

    @ViewBuilder
    private func contentView(_ viewStore: ViewStore<State, Action>) -> some View {
        switch viewStore.state {
        case .idle:
            idle()

        case .loading:
            ProgressView()

        default:
            EmptyView()
        }
    }
}

extension LoadingView where IdleContent == EmptyView {

    init(
        store: Store<State, Action>,
        @ViewBuilder success: @escaping (Store<Success, Action>) -> SuccessContent
    ) {
        self.init(store: store, success: success, idle: EmptyView.init)
    }
}

private struct LoadingFailureView<Action: Equatable>: View {

    let store: Store<FailureState<Action>, Action>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Spacing.padding3) {
                VStack(spacing: Spacing.textSpacing) {
                    Text(viewStore.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)

                    if let message = viewStore.message {
                        Text(message)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.body)
                    }
                }

                VStack(spacing: Spacing.padding1) {
                    ForEach(viewStore.buttons, id: \.title) { button in
                        view(for: button, viewStore: viewStore)
                    }
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder
    private func view(
        for button: FailureState<Action>.Button,
        viewStore: ViewStore<FailureState<Action>, Action>
    ) -> some View {
        switch button.style {
        case .cancel:
            MinimalButton(
                title: button.title,
                isLoading: button.loading,
                action: {
                    viewStore.send(button.action)
                }
            )

        case .destructive:
            DestructivePrimaryButton(
                title: button.title,
                isLoading: button.loading,
                action: {
                    viewStore.send(button.action)
                }
            )

        case .primary:
            BlockchainComponentLibrary.PrimaryButton(
                title: button.title,
                isLoading: button.loading,
                action: {
                    viewStore.send(button.action)
                }
            )
        }
    }
}
