import BlockchainUI
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
import FeatureDexUI
import FeatureQRCodeScannerUI
import FeatureReferralDomain
import FeatureReferralUI
import FeatureStakingUI
import FeatureWithdrawalLocksDomain
import FeatureWithdrawalLocksUI
import PlatformKit
import SafariServices
import UnifiedActivityDomain
import UnifiedActivityUI

@MainActor
public struct SiteMap {
    let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    @ViewBuilder public func view(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        let story = try ref.tag.as(blockchain.ux.type.story)
        switch ref.tag {
        case blockchain.ux.user.portfolio:
            PortfolioView()
        case blockchain.ux.prices:
            PricesView()
        case blockchain.ux.user.rewards:
            RewardsView()
        case blockchain.ux.user.activity:
            ActivityView()
        case blockchain.ux.nft.collection:
            AssetListViewController()
        case blockchain.ux.web:
            try SafariView(url: ref.context[blockchain.ux.web].decode())
                .ignoresSafeArea(.container, edges: .bottom)
        case blockchain.ux.user.activity.all:
            if #available(iOS 15.0, *) {
                let typeForAppMode: PresentedAssetType = app.currentMode == .trading ? .custodial : .nonCustodial
                let modelOrDefault = (try? context.decode(blockchain.ux.user.activity.all.model, as: PresentedAssetType.self)) ?? typeForAppMode
                let reducer = AllActivityScene(
                    activityRepository: resolve(),
                    custodialActivityRepository: resolve(),
                    app: app
                )
                AllActivitySceneView(
                    store: .init(
                        initialState: .init(with: modelOrDefault),
                        reducer: reducer
                    )
                )
            } else {
                // Fallback on earlier versions
            }
        case blockchain.ux.currency.exchange.router:
            ProductRouterView()
        case blockchain.ux.user.assets.all:
            if #available(iOS 15.0, *) {
                try AllAssetsSceneView(store: .init(
                    initialState: .init(with: context.decode(blockchain.ux.user.assets.all.model)),
                    reducer: AllAssetsScene(
                        assetBalanceInfoRepository: resolve(),
                        app: app
                    )
                ))
            } else {
                // Fallback on earlier versions
            }
        case blockchain.ux.activity.detail:
            if #available(iOS 15.0, *) {
                try ActivityDetailSceneView(
                    store: .init(
                        initialState: .init(activityEntry: context.decode(blockchain.ux.activity.detail.model)),
                        reducer: ActivityDetailScene(
                            app: resolve(),
                            activityDetailsService: resolve(),
                            custodialActivityDetailsService: resolve()
                        )
                    )
                )
            }
        case blockchain.ux.asset:
            let currency = try ref.context[blockchain.ux.asset.id].decode(CryptoCurrency.self)
            CoinAdapterView(
                cryptoCurrency: currency,
                dismiss: {
                    app.post(value: true, of: story.article.plain.navigation.bar.button.close.tap.then.close.key(to: ref.context))
                }
            )
        case blockchain.ux.withdrawal.locks:
            WithdrawalLocksDetailsView(
                withdrawalLocks: try context.decode(
                    blockchain.ux.withdrawal.locks.info,
                    as: WithdrawalLocks.self
                )
            )
        case isDescendant(of: blockchain.ux.transaction):
            try transaction(for: ref, in: context)
        case blockchain.ux.earn, isDescendant(of: blockchain.ux.earn):
            try Earn(app).view(for: ref, in: context)
        case blockchain.ux.dashboard.fiat.account.action.sheet:
            let balanceInfo = try context[blockchain.ux.dashboard.fiat.account.action.sheet.asset].decode(AssetBalanceInfo.self)
            WalletActionSheetView(
                store: .init(
                    initialState: .init(with: balanceInfo),
                    reducer: WalletActionSheet(app: resolve())
                )
            )
        case blockchain.ux.frequent.action.brokerage.more:
            let list = try context[blockchain.ux.frequent.action.brokerage.more.actions].decode([FrequentAction].self)
            MoreFrequentActionsView(actionsList: list)
        case blockchain.ux.scan.QR:
            QRCodeScannerView(
                secureChannelRouter: resolve(),
                walletConnectService: resolve(),
                tabSwapping: resolve()
            )
            .identity(blockchain.ux.scan.QR)
            .ignoresSafeArea()
        case blockchain.ux.user.account:
            AccountView()
                .identity(blockchain.ux.user.account)
                .ignoresSafeArea(.container, edges: .bottom)
        case blockchain.ux.referral.details.screen:
            let model = try context[blockchain.ux.referral.details.screen.info].decode(Referral.self)
            ReferFriendView(store: .init(
                initialState: .init(referralInfo: model),
                reducer: ReferFriendModule.reducer,
                environment: .init(
                    mainQueue: .main
                )
            ))
            .identity(blockchain.ux.referral)
            .ignoresSafeArea()
        default:
            throw Error(message: "No view", tag: ref, context: context)
        }
    }
}

extension SiteMap {

    @MainActor @ViewBuilder func transaction(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        switch ref.tag {
        case blockchain.ux.transaction.disclaimer:
            let product = try ref[blockchain.ux.transaction.id].decode(AssetAction.self).earnProduct.decode(EarnProduct.self)
            EarnConsiderationsView(pages: product.considerations)
                .context([blockchain.user.earn.product.id: product.value])
        default:
            throw Error(message: "No view", tag: ref, context: context)
        }
    }
}

extension SiteMap {

    @MainActor
    struct Earn {

        let app: AppProtocol

        init(_ app: AppProtocol) { self.app = app }

        @MainActor @ViewBuilder func view(
            for ref: Tag.Reference,
            in context: Tag.Context = [:]
        ) throws -> some View {
            switch ref {
            case blockchain.ux.earn:
                EarnDashboard()
            case blockchain.ux.earn.portfolio.product.asset.summary:
                try EarnSummaryView()
                    .context(
                        [
                            blockchain.user.earn.product.id: ref.context[blockchain.ux.earn.portfolio.product.id].or(throw: "No product"),
                            blockchain.user.earn.product.asset.id: ref.context[blockchain.ux.earn.portfolio.product.asset.id].or(throw: "No asset")
                        ]
                    )
            case blockchain.ux.earn.discover.product.not.eligible:
                try EarnProductNotEligibleView(
                    story: ref[].as(blockchain.ux.earn.type.hub.product.not.eligible)
                )
                .context(
                    [
                        blockchain.ux.earn.discover.product.id: context[blockchain.user.earn.product.id].or(throw: "No product"),
                        blockchain.ux.earn.discover.product.asset.id: context[blockchain.user.earn.product.asset.id].or(throw: "No product")
                    ]
                )
            case blockchain.ux.earn.portfolio.product.asset.no.balance, blockchain.ux.earn.discover.product.asset.no.balance:
                try EarnProductAssetNoBalanceView(
                    story: ref[].as(blockchain.ux.earn.type.hub.product.asset.no.balance)
                )
                .context(
                    [
                        blockchain.ux.earn.discover.product.id: context[blockchain.user.earn.product.id].or(throw: "No product"),
                        blockchain.ux.earn.discover.product.asset.id: context[blockchain.user.earn.product.asset.id].or(throw: "No product")
                    ]
                )
            default:
                throw Error(message: "No view", tag: ref, context: context)
            }
        }
    }
}

extension SiteMap {

    struct Error: Swift.Error {
        let message: String
        let tag: Tag.Reference
        let context: Tag.Context
    }
}

extension SiteMap.Error: LocalizedError {
    var errorDescription: String? { "\(tag.string): \(message)" }
}

extension View {
    @ViewBuilder
    func identity(_ tag: Tag.Event, in context: Tag.Context = [:]) -> some View {
        id(tag.description)
            .accessibility(identifier: tag.description)
    }
}

public struct SafariView: UIViewControllerRepresentable {

    @Binding var url: URL

    public init(url: URL) {
        _url = .constant(url)
    }

    public init(url: Binding<URL>) {
        _url = url
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.preferredControlTintColor = UIColor(Color.accentColor)
        safariViewController.dismissButtonStyle = .close
        return safariViewController
    }

    public func updateUIViewController(_ safariViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}
