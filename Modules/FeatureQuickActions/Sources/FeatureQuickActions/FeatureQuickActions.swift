import BlockchainUI
import SwiftUI

public struct QuickAction: Codable, Hashable {
    var id: String
    var title: String
    var description: String?
    var icon: URL
    var enabled: Bool?
    var hidden: Bool?
    var select: L_blockchain_ui_type_action.JSON
    var context: Tag.Context?
}

public struct QuickActionsView: View {

    @BlockchainApp var app
    public let tag: L & I_blockchain_ux_dashboard_quick_action
    @State private var actions: [QuickAction]?

    public init(tag: L & I_blockchain_ux_dashboard_quick_action) {
        self.tag = tag
    }

    public var body: some View {
        if let actions = actions.emptyIfNilOrNotEmpty {
            HStack(spacing: 24.pt) {
                ForEach(actions, id: \.self) { action in
                    QuickActionView(tag: tag.button, quickAction: action)
                        .context(tag.button.id, action.id)
                }
            }
            .bindings {
                subscribe($actions, to: tag.list.configuration)
            }
        }
    }
}

struct QuickActionView: View {

    @BlockchainApp var app

    let tag: L & I_blockchain_ux_dashboard_quick_action_button
    let quickAction: QuickAction

    var isHidden: Bool { quickAction.hidden ?? false }
    var isEnabled: Bool { quickAction.enabled ?? true }

    var body: some View {
        if !isHidden {
            VStack(alignment: .center) {
                Button(
                    action: { $app.post(event: tag.paragraph.button.icon.tap, context: quickAction.context ?? [:]) },
                    label: { AsyncMedia(url: quickAction.icon) }
                )
                .buttonStyle(ButtonStyle(quickAction: quickAction))
                .iconColor(.semantic.title)
                .frame(width: 48.pt, height: 48.pt)
                Text(quickAction.title)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            }
            .batch {
                set(tag.paragraph.button.icon.tap, to: quickAction.select.toJSON())
            }
            .opacity(isEnabled ? 1 : 0.3)
            .disabled(!isEnabled)
        }
    }
}

// MARK: - More menu

private typealias L10n = LocalizationConstants.SuperApp.Dashboard

public struct MoreQuickActionSheet: View {
    @BlockchainApp var app
    var list: [QuickAction]
    let tag: L & I_blockchain_ux_dashboard_quick_action

    public init(tag: L & I_blockchain_ux_dashboard_quick_action, actionsList: [QuickAction]) {
        self.tag = tag
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
                ForEach(list, id: \.self) { item in
                    if !(item.hidden ?? false) {
                        QuickActionRow(tag: tag.button, item: item)
                            .tag(item.id)
                            .context(tag.button.id, item.id)
                    }
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

struct QuickActionRow: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    let tag: L & I_blockchain_ux_dashboard_quick_action_button
    var item: QuickAction

    var isEnabled: Bool { item.enabled ?? true }

    init(tag: L & I_blockchain_ux_dashboard_quick_action_button, item: QuickAction) {
        self.tag = tag
        self.item = item
    }

    var body: some View {
        TableRow(
            leading: {
                VStack {
                    Button(
                        action: {},
                        label: { AsyncMedia(url: item.icon) }
                    )
                    .buttonStyle(
                        CircularButtonStyle(
                            quickAction: item,
                            backgroundColor: .semantic.light
                        )
                    )
                    .iconColor(.semantic.title)
                    .frame(width: 24.pt, height: 24.pt)
                    .disabled(true)
                }
            },
            title: .init(item.title.localized()),
            byline: .init(item.description?.localized() ?? "")
        )
        .tableRowBackground(Color.semantic.background)
        .contentShape(Rectangle())
        .onTapGesture {
            $app.post(event: blockchain.ux.frequent.action.brokerage.more.close)
            $app.post(
                event: tag.paragraph.row.tap,
                context: item.context ?? [:]
            )
        }
        .batch {
            set(tag.paragraph.row.tap, to: item.select.toJSON())
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.3)
        .id(item.id)
    }
}

// MARK: - Private

struct ButtonStyle: SwiftUI.ButtonStyle {

    @Environment(\.iconColor) var iconColor

    let quickAction: QuickAction
    var backgroundColor: Color = Color.semantic.background

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(iconColor.mask(configuration.label))
            .padding(12.pt)
            .background(backgroundColor)
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct CircularButtonStyle: SwiftUI.ButtonStyle {

    @Environment(\.iconColor) var iconColor

    let quickAction: QuickAction
    var backgroundColor: Color = Color.semantic.background

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .mask(iconColor)
            .overlay(iconColor.mask(configuration.label))
            .background(backgroundColor)
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

let json: Any = [
    [
        "id": "buy",
        "title": "Buy",
        "icon": "https://login.blockchain.com/static/asset/icon/plus.svg",
        "select": [
            "then": [
                "emit": "blockchain.ux.frequent.action.brokerage.buy"
            ]
        ]
    ],
    [
        "id": "deposit",
        "title": "Deposit",
        "icon": "https://login.blockchain.com/static/asset/icon/receive.svg",
        "select": [
            "then": [
                "emit": "blockchain.ux.kyc.launch.verification"
            ]
        ]
    ],
    [
        "id": "sell",
        "title": "Sell",
        "icon": "https://login.blockchain.com/static/asset/icon/user.svg",
        "enabled": false,
        "select": [
            "then": [
                "emit": "blockchain.db.type.tag.none"
            ]
        ]
    ],
    [
        "id": "swap",
        "title": "Swap",
        "icon": "https://login.blockchain.com/static/asset/icon/coins.svg",
        "hidden": true,
        "select": [
            "then": [
                "emit": "blockchain.db.type.tag.none"
            ]
        ]
    ]
]

struct QuickActionsView_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            Spacer()
            QuickActionsView(tag: blockchain.ux.dashboard.quick.action)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .app(
            App.preview { app in
                try await app.set(blockchain.ux.dashboard.quick.action.list.configuration, to: json)
            }
        )
        .previewDisplayName("Quick Actions")
    }
}
