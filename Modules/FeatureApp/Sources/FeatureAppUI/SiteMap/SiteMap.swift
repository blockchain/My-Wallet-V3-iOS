import BlockchainUI
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
import FeatureQRCodeScannerUI
import FeatureStakingUI
import PlatformKit
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
        case blockchain.ux.activity:
            ActivityView()
        case blockchain.ux.all.activity:
            if #available(iOS 15.0, *) {
                try AllActivitySceneView(store: .init(
                    initialState: .init(with: context.decode(blockchain.ux.all.activity.model)),
                    reducer: AllActivityScene(activityRepository: resolve(),
                                              custodialActivityRepository: resolve(),
                                              app: app)))
            } else {
                // Fallback on earlier versions
            }
        case blockchain.ux.all.assets:
            if #available(iOS 15.0, *) {
                try AllAssetsSceneView(store: .init(
                    initialState: .init(with: context.decode(blockchain.ux.all.assets.model)),
                    reducer: AllAssetsScene(assetBalanceInfoRepository: resolve(),
                                            app: app)))
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
            QRCodeScannerView()
                .identity(blockchain.ux.scan.QR)
                .ignoresSafeArea()
        case blockchain.ux.user.account:
            AccountView()
                .identity(blockchain.ux.user.account)
                .ignoresSafeArea(.container, edges: .bottom)
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
            switch try ref.context.decode(blockchain.ux.transaction.id, as: AssetAction.self) {
            case .stakingDeposit:
                EarnConsiderationsView()
                    .context([blockchain.user.earn.product.id: "staking"])
            case .interestTransfer:
                EarnConsiderationsView()
                    .context([blockchain.user.earn.product.id: "savings"])
            case _:
                throw Error(
                    message: "No disclaimer for \(String(describing: ref.context[blockchain.ux.transaction.id]))",
                    tag: ref,
                    context: context
                )
            }

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
            case blockchain.ux.earn.portfolio.product.asset.no.balance, blockchain.ux.earn.discover.product.asset.no.balance:
                try EarnProductAssetNoBalanceView(
                    story: ref[].as(blockchain.ux.earn.type.hub.product.asset.no.balance)
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
