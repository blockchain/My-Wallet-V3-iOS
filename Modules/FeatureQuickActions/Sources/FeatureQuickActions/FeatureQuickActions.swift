import BlockchainUI
import SwiftUI

struct QuickAction: Codable, Hashable {
    var id: String
    var title: String
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

    struct ButtonStyle: SwiftUI.ButtonStyle {

        @Environment(\.iconColor) var iconColor

        let quickAction: QuickAction

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .overlay(iconColor.mask(configuration.label))
                .padding(12.pt)
                .background(Color.semantic.background)
                .clipShape(Circle())
                .opacity(configuration.isPressed ? 0.5 : 1)
        }
    }

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
