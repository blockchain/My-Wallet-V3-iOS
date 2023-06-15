import BlockchainUI
import SwiftUI

public struct CustodialOnboardingDashboardView: View {

    @ObservedObject var service: CustodialOnboardingService

    public init(service: CustodialOnboardingService) {
        self.service = service
    }

    public var body: some View {
        VStack(spacing: 16.pt) {
            MoneyValue.zero(currency: service.currency).headerView()
                .padding(.top)
            QuickActionsView()
                .padding(.vertical)
            CustodialOnboardingProgressView(progress: service.progress)
            CustodialOnboardingTaskListView(service: service)
        }
        .padding(.horizontal)
    }
}

struct CustodialOnboardingProgressView: View {

    let progress: Double

    var body: some View {
        TableRow(
            leading: {
                ProgressView(value: progress, total: 1)
                    .progressViewStyle(
                        BlockchainCircularProgressViewStyle(
                            stroke: .semantic.primary,
                            background: .semantic.light,
                            indeterminate: false,
                            lineCap: .round
                        )
                    )
                    .inscribed {
                        Text(Rational(approximating: progress).scaled(toDenominator: 3).string)
                            .typography(.paragraph2.slashedZero())
                            .scaledToFit()
                    }
                    .foregroundTexture(.semantic.primary)
                    .frame(maxWidth: 10.vw)
            },
            title: {
                Text(L10n.completeYourProfile)
                    .typography(.caption1)
                    .foregroundTexture(.semantic.muted)
            },
            byline: {
                Text(L10n.tradeCryptoToday)
                    .typography(.body2)
                    .foregroundTexture(.semantic.title)
            }
        )
        .background(Color.semantic.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CustodialOnboardingTaskListView: View {

    @BlockchainApp var app
    @ObservedObject var service: CustodialOnboardingService

    var body: some View {
        DividedVStack {
            CustodialOnboardingTaskRowView(
                icon: .email,
                tint: .semantic.defi,
                title: L10n.verifyYourEmail,
                description: L10n.completeIn30Seconds,
                state: service.state(for: .verifyEmail)
            )
            .onTapGesture {
                $app.post(event: blockchain.ux.user.custodial.onboarding.dashboard.verify.email.paragraph.row.tap)
            }
            CustodialOnboardingTaskRowView(
                icon: .identification,
                tint: .semantic.primary,
                title: L10n.verifyYourIdentity,
                description: L10n.completeIn3Minutes,
                state: service.state(for: .verifyIdentity)
            )
            .onTapGesture {
                $app.post(event: blockchain.ux.user.custodial.onboarding.dashboard.verify.identity.paragraph.row.tap)
            }
            CustodialOnboardingTaskRowView(
                icon: .cart,
                tint: .semantic.success,
                title: L10n.buyCrypto,
                description: L10n.completeIn10Seconds,
                state: service.state(for: .purchaseCrypto)
            )
            .onTapGesture {
                $app.post(event: blockchain.ux.user.custodial.onboarding.dashboard.buy.crypto.paragraph.row.tap)
            }
        }
        .backgroundTexture(.semantic.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .batch {
            set(blockchain.ux.user.custodial.onboarding.dashboard.verify.email.paragraph.row.tap.then.emit, to: blockchain.ux.user.custodial.onboarding.dashboard.configuration.verify.email)
            set(blockchain.ux.user.custodial.onboarding.dashboard.verify.identity.paragraph.row.tap.then.emit, to: blockchain.ux.user.custodial.onboarding.dashboard.configuration.verify.identity)
            set(blockchain.ux.user.custodial.onboarding.dashboard.buy.crypto.paragraph.row.tap.then.emit, to: blockchain.ux.user.custodial.onboarding.dashboard.configuration.buy.crypto)
        }
    }
}

struct CustodialOnboardingTaskRowView: View {

    enum ViewState {
        case todo, highlighted, done
    }

    let icon: Icon
    let tint: Color
    let title: String
    let description: String
    let state: ViewState

    var body: some View {
        TableRow(
            leading: {
                icon.small().color(tint)
                    .overlay(Group {
                        if state == .highlighted {
                            Circle()
                                .fill(Color.semantic.pink)
                                .frame(width: 8.pt, height: 8.pt)
                        }
                    }, alignment: .topTrailing)
            },
            title: {
                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            },
            byline: {
                Group {
                    if state == .done {
                        Text("Completed")
                            .foregroundColor(.semantic.success)
                    } else {
                        Text(description)
                            .foregroundColor(.semantic.text)
                    }
                }
                .typography(.caption1)
            },
            trailing: {
                if state == .done {
                    Icon.checkCircle.small().color(.semantic.success)
                } else {
                    Icon.chevronRight.small().color(tint)
                }
            }
        )
        .opacity(state == .todo ? 0.5 : 1)
        .backgroundTexture(.semantic.background)
    }
}

let preview_quick_actions: Any = [
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
    ]
]

struct CustodialOnboardingDashboardView_Previews: PreviewProvider {

    static var previews: some View {
        let app = App.preview { app in
            try await app.set(blockchain.ux.user.custodial.onboarding.dashboard.quick.action.list.configuration, to: preview_quick_actions)
            try await app.set(blockchain.user.email.is.verified, to: false)
            try await app.set(blockchain.user.is.verified, to: false)
        }
        let (onVerifyEmail, onVerifyIdentity) = (
            app.on(blockchain.ux.user.custodial.onboarding.dashboard.verify.email) { _ async throws in
                try await app.set(blockchain.user.email.is.verified, to: !app.get(blockchain.user.email.is.verified))
            }.subscribe(),
            app.on(blockchain.ux.user.custodial.onboarding.dashboard.verify.identity) { _ async throws in
                try await app.set(blockchain.user.is.verified, to: !app.get(blockchain.user.is.verified))
            }.subscribe()
        )
        let service = CustodialOnboardingService()
        withDependencies { dependencies in
            dependencies.app = app
        } operation: {
            VStack {
                CustodialOnboardingDashboardView(service: service)
                Spacer()
            }
            .padding()
            .background(Color.semantic.light.ignoresSafeArea())
            .app(app)
            .onAppear {
                withExtendedLifetime((onVerifyEmail, onVerifyIdentity)) {
                    service
                }.request()
            }
        }
        .previewDisplayName("Dashboard")
    }
}

struct CustodialOnboardingProgressView_Previews: PreviewProvider {

    static var previews: some View {
        let app = App.preview
        withDependencies { dependencies in
            dependencies.app = app
        } operation: {
            VStack {
                Spacer()
                CustodialOnboardingProgressView(progress: 0 / 3).padding(.horizontal)
                CustodialOnboardingProgressView(progress: 1 / 3).padding(.horizontal)
                CustodialOnboardingProgressView(progress: 2 / 3).padding(.horizontal)
                Spacer()
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .app(app)
        }
        .previewDisplayName("Profile Progress")
    }
}

struct QuickActionsView_Previews: PreviewProvider {

    static var previews: some View {
        let app = App.preview { app in
            try await app.set(blockchain.ux.user.custodial.onboarding.dashboard.quick.action.list.configuration, to: preview_quick_actions)
        }
        withDependencies { dependencies in
            dependencies.app = app
        } operation: {
            VStack {
                Spacer()
                QuickActionsView()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.semantic.light.ignoresSafeArea())
            .app(app)
        }
        .previewDisplayName("Quick Actions")
    }
}
