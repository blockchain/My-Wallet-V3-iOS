// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import UIComponentsKit

struct ErrorRecoveryState: Equatable {

    struct Callout: Equatable, Identifiable {
        let id: AnyHashable
        let image: ImageLocation
        let title: String
        let message: String
        let callToAction: String

        init(
            id: AnyHashable = UUID(),
            image: ImageLocation,
            title: String,
            message: String,
            callToAction: String
        ) {
            self.id = id
            self.image = image
            self.title = title
            self.message = message
            self.callToAction = callToAction
        }

        static func == (lhs: Callout, rhs: Callout) -> Bool {
            lhs.title == rhs.title
                && lhs.message == rhs.message
                && lhs.image == rhs.image
                && lhs.callToAction == rhs.callToAction
        }
    }

    let title: String
    let message: String
    let callouts: [Callout]
}

struct ErrorRecovery: ReducerProtocol {

    enum Action {
        case closeTapped
        case calloutTapped(ErrorRecoveryState.Callout)
    }

    let close: () -> Void
    let calloutTapped: (ErrorRecoveryState.Callout) -> Void

    var body: some ReducerProtocol<ErrorRecoveryState, Action> {
        Reduce { state, action in
            switch action {
            case .closeTapped:
                close()
                return .none
            case .calloutTapped(let callout):
                calloutTapped(callout)
                return .none
            }
        }
    }
}

struct ErrorRecoveryView: View {

    let store: StoreOf<ErrorRecovery>
    let viewStore: ViewStoreOf<ErrorRecovery>

    init(store: StoreOf<ErrorRecovery>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(alignment: .top) {
                Text(viewStore.title)
                    .typography(.body2)
                    .padding([.top], 12) // half the close button size
                Spacer()
                IconButton(
                    icon: .navigationCloseButton(),
                    action: { viewStore.send(.closeTapped) }
                )
                .frame(width: 24, height: 24)
            }
            content
                .padding([.top], Spacing.padding2)
        }
        .padding(Spacing.padding3)
        .background(Color.semantic.background)
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.padding2) {
            RichText(viewStore.message)
                .typography(.paragraph1)
            ForEach(viewStore.callouts, id: \.title) { callout in
                CalloutCard(
                    leading: { callout.image.image },
                    title: callout.title,
                    message: callout.message,
                    control: Control(
                        title: callout.callToAction,
                        action: {
                            viewStore.send(.calloutTapped(callout))
                        }
                    )
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ErrorRecoveryView_Previews: PreviewProvider {

    static var state: ErrorRecoveryState {
        ErrorRecoveryState(
            title: "Lorem Ipsum",
            message: "Lorem ipsum **dolor sit** amet, consectetur adipiscing elit. Aliquam nunc urna, *gravida* commodo justo cursus, convallis lobortis diam.",
            callouts: [
                .init(
                    image: .local(name: "circle-locked-icon", bundle: .main),
                    title: "Mauris quis quam non nibh imperdiet vestibulum.",
                    message: "Praesent molestie, leo nec gravida.",
                    callToAction: "GO"
                ),
                .init(
                    id: "Some identifier",
                    image: .local(name: "circle-locked-icon", bundle: .main),
                    title: "Mauris quis quam non nibh imperdiet vestibulum.",
                    message: "Praesent molestie, leo nec gravida.",
                    callToAction: "GO"
                )
            ]
        )
    }

    static var previews: some View {
        ErrorRecoveryView(
            store: Store(
                initialState: state,
                reducer: ErrorRecovery(
                    close: {},
                    calloutTapped: { _ in }
                )
            )
        )
    }
}
