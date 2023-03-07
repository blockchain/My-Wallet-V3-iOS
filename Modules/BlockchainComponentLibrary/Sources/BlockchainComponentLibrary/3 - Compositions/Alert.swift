// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct Alert<TopView: View>: View {

    public struct Button {

        public enum Style {
            case primary, standard, destructive
        }

        let title: String
        let style: Style
        let action: () -> Void

        public init(title: String, style: Style, action: @escaping () -> Void) {
            self.title = title
            self.style = style
            self.action = action
        }
    }

    private let topView: () -> TopView?
    private let title: String?
    private let message: String?
    private let buttons: [Alert.Button]
    private let close: () -> Void

    public init(
        @ViewBuilder topView: @escaping () -> TopView?,
        title: String?,
        message: String?,
        buttons: [Alert.Button],
        close: @escaping () -> Void
    ) {
        self.topView = topView
        self.title = title
        self.message = message
        self.buttons = buttons
        self.close = close
    }

    public var body: some View {
        VStack {
            Spacer()

            VStack(spacing: Spacing.padding2) {
                HStack {
                    Spacer()
                    Icon.closeCirclev2
                        .frame(width: 24, height: 24)
                        .onTapGesture(perform: close)
                }

                // The check for EmptyView is not ideal but
                // returning a nil TopView doesn't compile.
                // This might be related to a bug fixed in Swift 5.4: https://forums.swift.org/t/nil-requires-contextual-type-swiftui-function-builder-bug/46915
                if let topView = topView(), !(topView is EmptyView) {
                    topView
                }

                if title != nil || message != nil {
                    VStack(spacing: Spacing.padding1) {
                        if let title {
                            Text(title)
                                .typography(.title3)
                                .foregroundColor(.semantic.title)
                        }

                        if let message {
                            Text(message)
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.body)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: Spacing.padding1) {
                    ForEach(buttons, id: \.title) { button in
                        buttonView(for: button)
                    }
                }
                .padding(.top, Spacing.padding1)
            }
            .multilineTextAlignment(.center)
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                    .fill(Color.semantic.background)
            )
            .frame(maxWidth: 320)
            .padding(Spacing.padding3)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.semantic.fadedBackground)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func buttonView(for button: Alert.Button) -> some View {
        switch button.style {
        case .primary:
            PrimaryButton(title: button.title, action: button.action)
        case .standard:
            MinimalButton(title: button.title, action: button.action)
        case .destructive:
            DestructivePrimaryButton(title: button.title, action: button.action)
        }
    }
}

extension Alert where TopView == EmptyView {

    public init(
        title: String?,
        message: String?,
        buttons: [Alert.Button],
        close: @escaping () -> Void
    ) {
        self.init(
            topView: EmptyView.init, // using a closure returning nil doesn't compile
            title: title,
            message: message,
            buttons: buttons,
            close: close
        )
    }
}

struct Alert_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            Alert(
                topView: {
                    Icon.blockchain
                        .frame(width: 24, height: 24)
                },
                title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                message: "Etiam pharetra, velit vitae convallis elementum, velit ex efficitur justo, et hendrerit lorem turpis dignissim augue.",
                buttons: [
                    Alert.Button(
                        title: "Primary Button",
                        style: .primary,
                        action: {}
                    ),
                    Alert.Button(
                        title: "Standard Button",
                        style: .standard,
                        action: {}
                    ),
                    Alert.Button(
                        title: "Destructive Button",
                        style: .destructive,
                        action: {}
                    )
                ],
                close: {}
            )
        }

        Group {
            Alert(
                title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                message: "Etiam pharetra, velit vitae convallis elementum, velit ex efficitur justo, et hendrerit lorem turpis dignissim augue.",
                buttons: [
                    Alert.Button(
                        title: "Primary Button",
                        style: .primary,
                        action: {}
                    ),
                    Alert.Button(
                        title: "Standard Button",
                        style: .standard,
                        action: {}
                    ),
                    Alert.Button(
                        title: "Destructive Button",
                        style: .destructive,
                        action: {}
                    )
                ],
                close: {}
            )
        }

        Group {
            Alert(
                title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                message: "Etiam pharetra, velit vitae convallis elementum, velit ex efficitur justo, et hendrerit lorem turpis dignissim augue.",
                buttons: [],
                close: {}
            )
        }

        Group {
            Alert(
                title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                message: nil,
                buttons: [
                    Alert.Button(
                        title: "Primary Button",
                        style: .primary,
                        action: {}
                    )
                ],
                close: {}
            )
        }

        Group {
            Alert(
                title: nil,
                message: "Etiam pharetra, velit vitae convallis elementum, velit ex efficitur justo, et hendrerit lorem turpis dignissim augue.",
                buttons: [
                    Alert.Button(
                        title: "Primary Button",
                        style: .primary,
                        action: {}
                    )
                ],
                close: {}
            )
        }

        Group {
            Alert(
                title: nil,
                message: nil,
                buttons: [
                    Alert.Button(
                        title: "Primary Button",
                        style: .primary,
                        action: {}
                    )
                ],
                close: {}
            )
        }

        Group {
            Alert(
                title: nil,
                message: nil,
                buttons: [],
                close: {}
            )
        }
    }
}
