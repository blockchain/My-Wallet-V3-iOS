import BlockchainUI
import SwiftUI

struct QuickAction: Codable, Hashable {
    var id: String
    var title: String
    var icon: URL
    var select: L_blockchain_ui_type_action.JSON
    var context: Tag.Context?
}

struct QuickActionsView: View {

    @BlockchainApp var app

    @State var actions: [QuickAction]?

    var body: some View {
        if let actions = actions.emptyIfNilOrNotEmpty {
            HStack(spacing: 24.pt) {
                ForEach(actions, id: \.self) { action in
                    QuickActionView(quickAction: action)
                        .context(blockchain.ux.user.custodial.onboarding.dashboard.quick.action.button.id, action.id)
                }
            }
            .bindings {
                subscribe($actions, to: blockchain.ux.user.custodial.onboarding.dashboard.quick.action.list.configuration)
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
    let id = blockchain.ux.user.custodial.onboarding.dashboard.quick.action.button.paragraph.button.icon

    let quickAction: QuickAction

    var body: some View {
        VStack(alignment: .center) {
            Button(
                action: { $app.post(event: id.tap, context: quickAction.context ?? [:]) },
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
            set(id.tap, to: quickAction.select.toJSON())
        }
    }
}

struct QuickActionsView_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            Spacer()
            QuickActionsView()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .app(
            App.preview { app in
                try await app.set(blockchain.ux.user.custodial.onboarding.dashboard.quick.action.list.configuration, to: preview_quick_actions)
            }
        )
        .previewDisplayName("Quick Actions")
    }
}
