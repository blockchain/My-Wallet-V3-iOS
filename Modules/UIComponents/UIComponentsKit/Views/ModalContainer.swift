// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

typealias IconButtonFromBlockchainComponentLibrary = BlockchainComponentLibrary.IconButton

public struct ModalContainer<TopAccessory: View, Content: View>: View {

    public enum HeaderStyle {
        case small
        case medium
        case large
    }

    private let title: String?
    private let subtitle: String?
    private let headerStyle: HeaderStyle
    private let closeAction: () -> Void
    @ViewBuilder private let topAccessory: () -> TopAccessory
    @ViewBuilder private let content: () -> Content

    public init(
        title: String?,
        subtitle: String?,
        headerStyle: HeaderStyle = .large,
        onClose closeAction: @escaping () -> Void,
        @ViewBuilder topAccessory: @escaping () -> TopAccessory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.headerStyle = headerStyle
        self.closeAction = closeAction
        self.topAccessory = topAccessory
        self.content = content
    }

    public var body: some View {
        VStack(spacing: Spacing.padding3) {
            header()

            content()
                .frame(maxWidth: .infinity)
        }
        .background(Color.semantic.background)
    }

    @ViewBuilder
    private func header() -> some View {
        switch headerStyle {
        case .small:
            smallHeader
        case .medium:
            mediumHeader
        case .large:
            largeHeader
        }
    }

    private var smallHeader: some View {
        VStack(spacing: Spacing.padding1) {
            closeHandle
            HStack(alignment: .top, spacing: Spacing.padding2) {
                VStack(alignment: .leading, spacing: Spacing.baseline) {
                    if let title {
                        Text(title)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 12) // pad to half the close button

                Spacer()

                closeButton
            }
            .padding(.horizontal, Spacing.padding3)
        }
    }

    private var mediumHeader: some View {
        VStack(spacing: Spacing.padding2) {
            VStack(spacing: Spacing.padding1) {
                closeHandle

                HStack(alignment: .top) {
                    Spacer()
                    closeButton
                }
            }
            .padding(.horizontal, Spacing.padding3)

            topAccessory()

            if title != nil || subtitle != nil {
                VStack(spacing: Spacing.baseline) {
                    if let title {
                        Text(title)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, Spacing.padding3)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var largeHeader: some View {
        VStack(spacing: Spacing.padding2) {
            VStack(spacing: Spacing.padding1) {
                closeHandle

                HStack(alignment: .top) {
                    Spacer()
                    closeButton
                }
            }
            .padding(.horizontal, Spacing.padding3)

            topAccessory()

            if title != nil || subtitle != nil {
                VStack(spacing: Spacing.baseline) {
                    if let title {
                        Text(title)
                            .typography(.title2)
                            .foregroundColor(.semantic.title)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, Spacing.padding3)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var closeHandle: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.semantic.medium)
            .frame(width: 32, height: 4)
            .padding(.top, Spacing.padding2)
            .padding(.bottom, Spacing.padding1)
            .onTapGesture(perform: closeAction)
    }

    private var closeButton: some View {
        Icon
            .close
            .onTapGesture {
                closeAction()
            }
            .frame(width: 24, height: 24)
    }
}

extension ModalContainer where TopAccessory == EmptyView {

    public init(
        onClose closeAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: nil,
            subtitle: nil,
            onClose: closeAction,
            topAccessory: EmptyView.init,
            content: content
        )
    }

    public init(
        title: String,
        onClose closeAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            subtitle: nil,
            headerStyle: .small,
            onClose: closeAction,
            topAccessory: EmptyView.init,
            content: content
        )
    }

    public init(
        title: String,
        subtitle: String,
        headerStyle: HeaderStyle = .large,
        onClose closeAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            headerStyle: headerStyle,
            onClose: closeAction,
            topAccessory: EmptyView.init,
            content: content
        )
    }
}

struct ModalContainer_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ModalContainer(
                onClose: { print("Close") },
                content: {
                    Color.red
                }
            )

            ModalContainer(
                title: "My Modal",
                onClose: { print("Close") },
                content: {
                    Color.red
                }
            )

            ModalContainer(
                title: "My Modal",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                onClose: { print("Close") },
                content: {
                    Color.red
                }
            )

            ModalContainer(
                title: "My Modal",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                headerStyle: .small,
                onClose: { print("Close") },
                content: {
                    Color.red
                }
            )

            ModalContainer(
                title: "My Modal",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                onClose: { print("Close") },
                topAccessory: {
                    Icon.blockchain
                        .frame(width: 32, height: 32)
                },
                content: {
                    Color.red
                }
            )
        }
    }
}
