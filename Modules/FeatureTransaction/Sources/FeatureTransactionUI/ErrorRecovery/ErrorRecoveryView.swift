// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import UIComponentsKit

struct ErrorRecoveryState: Equatable {

    struct Callout: Equatable, Identifiable {
        let id: AnyHashable
        let image: Image
        let title: String
        let message: String
        let callToAction: String

        init(
            id: AnyHashable = UUID(),
            image: Image,
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

enum ErrorRecoveryAction {
    case closeTapped
    case calloutTapped(ErrorRecoveryState.Callout)
}

struct ErrorRecoveryEnvironment {
    let close: () -> Void
    let calloutTapped: (ErrorRecoveryState.Callout) -> Void
}

let errorRecoveryReducer = Reducer<
    ErrorRecoveryState,
    ErrorRecoveryAction,
    ErrorRecoveryEnvironment
> { _, action, environment in
    switch action {
    case .closeTapped:
        environment.close()
        return .none

    case .calloutTapped(let callout):
        environment.calloutTapped(callout)
        return .none
    }
}

struct ErrorRecoveryView: View {

    let store: Store<ErrorRecoveryState, ErrorRecoveryAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            BottomSheetModal(
                title: viewStore.title,
                onClose: { viewStore.send(.closeTapped) },
                content: {
                    VStack(alignment: .leading, spacing: Spacing.padding2) {
                        RichText(viewStore.message)
                            .typography(.paragraph1)
                        ForEach(viewStore.callouts, id: \.title) { callout in
                            CalloutCard(
                                leading: {
                                    callout.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                },
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
            )
        }
    }
}

// TODO: extract to a component: IOS-5791
/// A helper compoent to create bottom sheet modals. It shows a content underneat a header.
/// The header contains a title and a close button.
///  [Figma](https://www.figma.com/file/Tifx5rsJqUS6oqmrOC4kh1/Limits?node-id=727%3A18555)
struct BottomSheetModal<Content: View>: View {

    private let title: String
    private let closeAction: () -> Void
    @ViewBuilder private let content: () -> Content

    init(
        title: String,
        onClose: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.closeAction = onClose
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(alignment: .top) {
                Text(title)
                    .typography(.body2)
                    .padding([.top], 12) // half the close button size
                Spacer()
                IconButton(icon: .closev2.circle(), action: closeAction)
                    .frame(width: 24, height: 24)
            }
            content()
                .padding([.top], Spacing.padding2)
        }
        .padding(Spacing.padding3)
        .background(Color.semantic.background)
    }
}

struct ErrorRecoveryView_Previews: PreviewProvider {

    static var previews: some View {
        ErrorRecoveryView(
            store: .init(
                initialState: ErrorRecoveryState(
                    title: "Lorem Ipsum",
                    message: "Lorem ipsum **dolor sit** amet, consectetur adipiscing elit. Aliquam nunc urna, *gravida* commodo justo cursus, convallis lobortis diam.",
                    callouts: [
                        .init(
                            image: ImageResource.local(
                                name: "circle-locked-icon",
                                bundle: .main
                            ).image!,
                            title: "Mauris quis quam non nibh imperdiet vestibulum.",
                            message: "Praesent molestie, leo nec gravida.",
                            callToAction: "GO"
                        ),
                        .init(
                            id: "Some identifier",
                            image: ImageResource.local(
                                name: "circle-locked-icon",
                                bundle: .main
                            ).image!,
                            title: "Mauris quis quam non nibh imperdiet vestibulum.",
                            message: "Praesent molestie, leo nec gravida.",
                            callToAction: "GO"
                        )
                    ]
                ),
                reducer: errorRecoveryReducer,
                environment: ErrorRecoveryEnvironment(
                    close: {},
                    calloutTapped: { _ in }
                )
            )
        )
    }
}
