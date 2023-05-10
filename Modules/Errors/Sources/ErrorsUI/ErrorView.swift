import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI

public struct ErrorView<Fallback: View>: View {

    typealias L10n = LocalizationConstants.UX.Error

    @BlockchainApp var app
    @Environment(\.context) var context

    public let ux: UX.Error
    public let navigationBarClose: Bool
    public let fallback: () -> Fallback
    public let dismiss: (() -> Void)?

    public init(
        ux: UX.Error,
        navigationBarClose: Bool = true,
        @ViewBuilder fallback: @escaping () -> Fallback,
        dismiss: (() -> Void)? = nil
    ) {
        self.ux = ux
        self.navigationBarClose = navigationBarClose
        self.fallback = fallback
        self.dismiss = dismiss
    }

    let overlay = 7.5

    public var body: some View {
        VStack {
            VStack(spacing: .none) {
                Spacer()    
                icon
                content.layoutPriority(1)
                Spacer()
                metadata
            }
            .multilineTextAlignment(.center)
            actions
        }
        .foregroundTexture(ux.dialog?.style?.foreground)
        .backgroundTexture(ux.dialog?.style?.background)
        .padding()
        .onAppear {
            app.state.transaction { state in
                state.set(blockchain.ux.error, to: ux)
            }
            app.post(
                event: blockchain.ux.error,
                context: context + ux.context(in: app)
            )
        }
        #if os(iOS)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: EmptyView(),
            trailing: Group {
                if navigationBarClose {
                     trailingNavigationBarItem
                 }
             }
        )
        #endif
        .background(Color.semantic.background)
    }

    @ViewBuilder var trailingNavigationBarItem: some View {
        if let dismiss {
            IconButton(
                icon: Icon.closeCirclev2,
                action: dismiss
            )
        }
    }

    @ViewBuilder
    private var icon: some View {
        Group {
            if let icon = ux.icon {
                AsyncMedia(
                    url: icon.url,
                    placeholder: {
                        Image(systemName: "squareshape.squareshape.dashed")
                            .resizable()
                            .overlay(ProgressView().opacity(0.3))
                            .foregroundColor(.semantic.light)
                    }
                )
                .accessibilityLabel(icon.accessibility?.description ?? L10n.icon.accessibility)
            } else {
                fallback()
            }
        }
        .scaledToFit()
        .frame(minHeight: 80.pt, maxHeight: 100.pt)
        .padding(floor(overlay / 2).i.vmin)
        .overlay(
            Group {
                if let status = ux.icon?.status?.url {
                    ZStack {
                        Circle()
                            .foregroundColor(.semantic.background)
                            .scaleEffect(1.3)

                        AsyncMedia(
                            url: status,
                            content: { image in image.scaleEffect(0.9) },
                            placeholder: {
                                ProgressView().progressViewStyle(.circular)
                            }
                        )
                    }
                    .frame(
                        width: overlay.vmin,
                        height: overlay.vmin
                    )
                    .offset(x: -overlay, y: overlay)
                }
            },
            alignment: .topTrailing
        )
    }

    @ViewBuilder
    private var content: some View {
        if ux.title.isNotEmpty {
            Text(rich: ux.title)
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.bottom, Spacing.padding1.pt)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        if ux.message.isNotEmpty {
            Text(rich: ux.message)
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.bottom, Spacing.padding2.pt)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        if let action = ux.actions.dropFirst(2).first, action.title.isNotEmpty {
            SmallMinimalButton(
                title: action.title,
                action: { post(action) }
            )
        }
    }

    private var columns: [GridItem] = [
        GridItem(.flexible(minimum: 32, maximum: 48), spacing: 16),
        GridItem(.flexible(minimum: 100, maximum: .infinity), spacing: 16)
    ]

    @ViewBuilder
    private var metadata: some View {
        if !ux.metadata.isEmpty {
            HStack {
                LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(Array(ux.metadata), id: \.key) { key, value in
                        Text(rich: key)
                        Text(rich: value)
                    }
                }
                .frame(maxWidth: .infinity)
                Icon.copy
                    .color(.semantic.light)
                    .frame(width: 16.pt, height: 16.pt)
            }
            .typography(.micro)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .foregroundColor(.semantic.body)
            .padding(8.pt)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.semantic.light, lineWidth: 1)
                    .background(Color.semantic.background)
            )
            .contextMenu {
                Button(
                    action: {
                        let string = String(ux.metadata.map { "\($0): \($1)" }.joined(by: "\n"))
                        #if canImport(UIKit)
                        UIPasteboard.general.string = string
                        #else
                        NSPasteboard.general.setString(string, forType: .string)
                        #endif
                    },
                    label: {
                        Label(L10n.copy, systemImage: "doc.on.doc.fill")
                    }
                )
            }
            .padding(.bottom)
        }
    }

    @ViewBuilder
    private var actions: some View {
        VStack(spacing: Spacing.padding1) {
            ForEach(ux.actions.prefix(2).indexed(), id: \.element) { index, action in
                if action.title.isNotEmpty {
                    if index == ux.actions.startIndex {
                        PrimaryButton(
                            title: action.title,
                            action: { post(action) }
                        )
                    } else {
                        MinimalButton(
                            title: action.title,
                            action: { post(action) }
                        )
                    }
                }
            }
        }
    }

    private func post(_ action: UX.Action) {
        switch action.url {
        case let url?:
            app.post(
                event: blockchain.ux.error.then.launch.url,
                context: [
                    blockchain.ui.type.action.then.launch.url: url
                ]
            )
        case nil:
            $app.post(event: blockchain.ux.error.dismiss.paragraph.button.primary.tap)
            if let dismiss {
                dismiss()
            } else {
                app.post(event: blockchain.ux.error.then.close)
            }
        }
    }
}

extension ErrorView where Fallback == AnyView {

    public init(
        ux: UX.Error,
        navigationBarClose: Bool = true,
        dismiss: (() -> Void)? = nil
    ) {
        self.ux = ux
        self.navigationBarClose = navigationBarClose
        self.fallback = {
            AnyView(
                Icon.error.color(.semantic.warning)
            )
        }
        self.dismiss = dismiss
    }
}

// swiftlint:disable type_name
struct ErrorView_Preview: PreviewProvider {

    static var previews: some View {
        ErrorView(
            ux: .init(
                title: "Error Title",
                message: "Here’s some explainer text that helps the user understand the problem, with a [potential link](http://blockchain.com) for the user to tap to learn more."
            )
        )
        .app(App.preview)
    }
}
