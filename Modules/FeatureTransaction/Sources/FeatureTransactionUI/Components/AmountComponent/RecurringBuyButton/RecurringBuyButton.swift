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
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.buttonTapped)
            } label: {
                HStack(spacing: BlockchainComponentLibrary.Spacing.padding1) {
                    Icon
                        .clock
                        .micro()
                        .color(.semantic.text)

                    if let title = viewStore.title {
                        Text(title)
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
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
            .if(viewStore.highlighted, then: { view in
                view.highlighted()
            })
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
    @BindingState var title: String?
    @BindingState var highlighted: Bool = false
    init(
        title: String? = nil
    ) {
        self.title = title
    }
}

enum RecurringBuyButtonAction: Equatable, BindableAction {
    case buttonTapped
    case refresh
    case binding(BindingAction<RecurringBuyButtonState>)
}

struct RecurringBuyButtonReducer: Reducer {
    
    typealias State = RecurringBuyButtonState
    typealias Action = RecurringBuyButtonAction

    let app: AppProtocol
    let recurringBuyButtonTapped: () -> Void

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .refresh:
                return .merge(
                    .publisher {
                        app.publisher(for: blockchain.ux.transaction.checkout.recurring.buy.frequency.localized, as: String.self)
                            .receive(on: DispatchQueue.main)
                            .compactMap(\.value)
                            .map { .binding(.set(\.$title, $0)) }
                    },
                    .publisher {
                        app.publisher(for: blockchain.ux.transaction.recurring.buy.button.tapped.once, as: Bool.self)
                            .replaceError(with: false)
                            .receive(on: DispatchQueue.main)
                            .map { .binding(.set(\.$highlighted, !$0)) }
                    }
                )
            case .buttonTapped:
                return .run { _ in
                    app.post(value: true, of: blockchain.ux.transaction.recurring.buy.button.tapped.once)
                    recurringBuyButtonTapped()
                }
            case .binding:
                return .none
            }
        }
    }
}

struct RecurringBuyButton_Previews: PreviewProvider {
    static var previews: some View {
        RecurringBuyButton(
            store: Store(
                initialState: .init(title: ""),
                reducer: { RecurringBuyButtonReducer(app: App.preview, recurringBuyButtonTapped: {}) }
            ),
            trailingView: { Icon.placeholder }
        )
    }
}
