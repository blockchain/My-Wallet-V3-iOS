// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import Localization
import SwiftUI

struct RecurringBuyButton<TrailingView: View>: View {

    @BlockchainApp var app
    private let store: Store<RecurringBuyButtonState, RecurringBuyButtonAction>
    private let trailingView: TrailingView

    init(
        store: Store<RecurringBuyButtonState, RecurringBuyButtonAction>,
        @ViewBuilder trailingView: () -> TrailingView
    ) {
        self.store = store
        self.trailingView = trailingView()
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            Button {
                viewStore.send(.buttonTapped)
            } label: {
                HStack(spacing: BlockchainComponentLibrary.Spacing.padding1) {
                    if let title = viewStore.title {
                        Text(title)
                            .typography(.body1)
                            .foregroundColor(.textTitle)
                    }

                    trailingView
                        .frame(width: 16.pt, height: 16.pt)
                }
                .padding([.leading, .trailing], 8.pt)
            }
            .padding(8.pt)
            .background(BlockchainComponentLibrary.Color.semantic.background)
            .clipShape(Capsule())
            .frame(minHeight: 32.pt)
            .opacity(viewStore.title == nil ? 0 : 1)
            .transition(.opacity)
            .animation(.easeInOut)
            .onAppear {
                viewStore.send(.refresh)
            }
            .onReceive(app.publisher(for: blockchain.ux.transaction.checkout.recurring.buy.frequency)) { _ in
                viewStore.send(.refresh)
            }
        }
    }
}

struct RecurringBuyButtonState: Equatable {
    @BindableState var title: String?

    init(
        title: String? = nil
    ) {
        self.title = title
    }
}

struct RecurringBuyButtonEnvironment {
    let app: AppProtocol
    let recurringBuyButtonTapped: () -> Void
}

enum RecurringBuyButtonAction: Equatable, BindableAction {
    case buttonTapped
    case refresh
    case binding(BindingAction<RecurringBuyButtonState>)
}

let recurringBuyButtonReducer = Reducer<
    RecurringBuyButtonState,
    RecurringBuyButtonAction,
    RecurringBuyButtonEnvironment
> { _, action, environment in
    switch action {
    case .refresh:
        return environment
            .app.publisher(for: blockchain.ux.transaction.checkout.recurring.buy.frequency.localized, as: String.self)
            .receive(on: DispatchQueue.main)
            .compactMap(\.value)
            .eraseToEffect()
            .map { .binding(.set(\.$title, $0)) }

    case .buttonTapped:
        return .fireAndForget {
            environment.recurringBuyButtonTapped()
        }
    case .binding:
        return .none
    }
}
.binding()

struct RecurringBuyButton_Previews: PreviewProvider {
    static var previews: some View {
        RecurringBuyButton(
            store: .init(
                initialState: .init(title: ""),
                reducer: recurringBuyButtonReducer,
                environment: .init(app: App.preview, recurringBuyButtonTapped: {})
            ),
            trailingView: { Icon.placeholder }
        )
    }
}
