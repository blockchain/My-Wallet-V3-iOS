// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI

private typealias L10n = LocalizationConstants.SuperApp.Dashboard

public struct FrequentActions: Codable, Equatable {
    public let withBalance: FrequentActionsContent
    public let zeroBalance: FrequentActionsContent

    public init(withBalance: FrequentActionsContent, zeroBalance: FrequentActionsContent) {
        self.withBalance = withBalance
        self.zeroBalance = zeroBalance
    }
}

public struct FrequentActionsContent: Codable, Equatable {
    public let list: [FrequentAction]
    public let buttons: [FrequentAction]

    public init(list: [FrequentAction], buttons: [FrequentAction]) {
        self.list = list
        self.buttons = buttons
    }
}

public struct FrequentAction: Hashable, Identifiable, Codable {
    public var id: String { tag.id }
    public let tag: Tag
    let name: String
    var icon: Icon
    let description: String
    var isEnabled: Bool? = true
    let context: Tag.Context?
    let tap: L_blockchain_ui_type_action.JSON?

    var contextOrEmpty: Tag.Context {
        context ?? [:]
    }
}

public struct FrequentActionsView: View {
    @BlockchainApp var app
    public var actions: FrequentActionsContent
    public var topPadding: CGFloat

    public init(
        actions: FrequentActionsContent,
        topPadding: CGFloat = Spacing.padding3
    ) {
        self.actions = actions
        self.topPadding = topPadding
    }

    public var body: some View {
        HStack(alignment: .center, spacing: Spacing.padding3) {
            ForEach(actions.buttons) { action in
                FrequentActionView(state: action) {
                    if action.tag == blockchain.ux.frequent.action.brokerage.more[] {
                        app.post(
                            event: blockchain.ux.frequent.action.brokerage.more.entry.paragraph.button.icon.tap,
                            context: [
                                blockchain.ux.frequent.action.brokerage.more.actions: actions.list,
                                blockchain.ui.type.action.then.enter.into.detents: [
                                    blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                                ]
                            ]
                        )
                    } else {
                        app.post(
                            event: action.tag,
                            context: action.contextOrEmpty
                        )
                    }
                }
                .context(action.contextOrEmpty)
                .accessibilityLabel(action.name)
                .batch {
                    if let tap = action.tap {
                        set(action.tag, to: tap)
                    }
                }
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, Spacing.padding2)
        .batch {
            set(blockchain.ux.frequent.action.swap.then.launch, to: blockchain.ux.transaction["swap"])
            set(blockchain.ux.frequent.action.receive.then.launch, to: blockchain.ux.transaction["deposit"])
            set(blockchain.ux.frequent.action.send.then.launch, to: blockchain.ux.transaction["withdraw"])
            set(blockchain.ux.frequent.action.sell.then.launch, to: blockchain.ux.transaction["sell"])
            set(
                blockchain.ux.frequent.action.brokerage.more.entry.paragraph.button.icon.tap.then.enter.into,
                to: blockchain.ux.frequent.action.brokerage.more
            )
            set(
                blockchain.ux.frequent.action.brokerage.more.article.plain.navigation.bar.button.close.tap.then.close,
                to: true
            )
        }
    }
}

public struct MoreFrequentActionsView: View {
    @BlockchainApp var app
    public var list: [FrequentAction]

    public init(actionsList: [FrequentAction]) {
        self.list = actionsList
    }

    public var body: some View {
        VStack {
            HStack {
                Text(L10n.QuickActions.more.localized())
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                Spacer()
                IconButton(icon: .closeCirclev2.small()) {
                    app.post(event: blockchain.ux.frequent.action.brokerage.more.article.plain.navigation.bar.button.close.tap)
                }
            }
            .padding([.leading, .trailing], Spacing.padding2)
            .padding([.top, .bottom], Spacing.padding2 + Spacing.textSpacing)
            DividedVStack {
                ForEach(list) { item in
                    FrequentActionRow(item: item)
                        .app(app)
                        .context(item.context ?? [:])
                }
            }
        }
        .batch {
            set(
                blockchain.ux.frequent.action.brokerage.more.article.plain.navigation.bar.button.close.tap.then.close,
                to: true
            )
            set(
                blockchain.ux.frequent.action.brokerage.more.close.then.close,
                to: true
            )
        }
        .background(Color.semantic.background.ignoresSafeArea())
    }
}

// MARK: - Row

struct FrequentActionRow: View {
    @BlockchainApp var app
    @Environment(\.context) var context
    @Environment(\.scheduler) var scheduler

    var item: FrequentAction

    @State private var isEligible: Bool = true

    private var isDisabled: Bool {
        if let isEnabled = item.isEnabled { return !isEnabled }
        return !isEligible
    }

    init(
        item: FrequentAction
    ) {
        self.item = item
    }

    var body: some View {
        PrimaryRow(
            title: item.name.localized(),
            subtitle: item.description.localized(),
            leading: {
                item.icon
                    .color(.semantic.title)
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 24.pt)
            },
            action: {
                Task {
                    app.post(event: blockchain.ux.frequent.action.brokerage.more.close)
                    try await scheduler.sleep(for: .seconds(0.3))
                    app.post(event: item.tag, context: context)
                }
            }
        )
        .disabled(isDisabled)
        .bindings {
            subscribe($isEligible, to: blockchain.api.nabu.gateway.products.is.eligible)
        }
        .opacity(isDisabled ? 0.5 : 1.0)
        .id(item.tag.description)
        .accessibility(identifier: item.tag.description)
    }
}

// MARK: - Circle View

struct FrequentActionView: View {
    var state: FrequentAction
    var action: () -> Void

    @Environment(\.context) var context

    @State private var isEligible: Bool = true
    private var isDisabled: Bool {
        if let isEnabled = state.isEnabled { return !isEnabled }
        return !isEligible
    }

    init(
        state: FrequentAction,
        action: @escaping () -> Void
    ) {
        self.state = state
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.textSpacing) {
            Button(action: action) {
                state.icon
                    .micro()
                    .color(.semantic.title)
            }
            .disabled(isDisabled)
            .bindings {
                subscribe($isEligible, to: blockchain.api.nabu.gateway.products.is.eligible)
            }
            Text(state.name.localized())
                .typography(.caption1)
                .foregroundColor(.semantic.text)
        }
        .buttonStyle(ButtonFrequentActionStyle())
    }
}

// MARK: - Action Button Style

private struct ButtonFrequentActionStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.semantic.background)
            .foregroundColor(.semantic.title)
            .clipShape(Circle())
            .opacity(isEnabled ? 1.0 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}
