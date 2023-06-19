import BlockchainUI
import DIKit
import FeatureCheckoutUI
import FeatureKYCUI
import FeatureReceiveUI
import FeatureStakingUI
import FeatureTransactionEntryUI
import FeatureTransactionUI
import PlatformKit
import RIBs
import SwiftUI

extension SiteMap {

    @MainActor @ViewBuilder func transaction(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        switch ref {
        case blockchain.ux.transaction:
            IfEligible { TransactionView() }
                .ignoresSafeArea()
                .navigationBarHidden(true)
        case blockchain.ux.transaction.disclaimer:
            let product = try ref[blockchain.ux.transaction.id].decode(AssetAction.self).earnProduct.decode(EarnProduct.self)
            EarnConsiderationsView(pages: product.considerations)
                .context([blockchain.user.earn.product.id: product.value])
        case blockchain.ux.transaction[AssetAction.buy].select.target:
            IfEligible { BuyEntryView() }
        case blockchain.ux.transaction[AssetAction.sell].select.source:
            IfEligible { SellEntryView() }
        case blockchain.ux.transaction.send.address.info:
            let address = try context[blockchain.ux.transaction.send.address.info.address].decode(String.self)
            AddressInfoModalView(address: address)
        default:
            throw Error(message: "No view", tag: ref, context: context)
        }
    }
}

struct TransactionView: UIViewControllerRepresentable {

    @BlockchainApp var app

    @Environment(\.context) var context
    @Environment(\.coincore) var coincore

    func makeUIViewController(context: Context) -> UIViewController {
        if let (viewController, router, listener) = build() {
            context.coordinator.router = router
            context.coordinator.listener = listener
            return viewController
        } else {
            return UIHostingController(rootView: Unsupported())
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        /* do nothing */
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {

        var listener: (any TransactionFlowListener)?
        var router: (any ViewableRouting)? {
            willSet {
                router?.interactable.deactivate()
            }
            didSet {
                router?.load()
                router?.interactable.activate()
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func build() -> (UIViewController, ViewableRouting, TransactionFlowListener)? {
        do {
            let builder = TransactionFlowBuilder()
            let action: AssetAction = try context.decode(blockchain.ux.transaction.id)
            switch action {
            case .buy:
                let interactor = BuyFlowInteractor()
                interactor.listener = BuyFlowListener()
                var target: TransactionTarget?
                if let asset = try? context.decode(blockchain.ux.asset.id, as: CryptoCurrency.self) {
                    target = coincore.cryptoTradingAccount(for: asset)
                }
                let router = builder.build(
                    withListener: interactor,
                    action: .buy,
                    sourceAccount: nil,
                    target: context[blockchain.ux.transaction.source.target] as? TransactionTarget ?? target,
                    order: context[blockchain.ux.transaction.checkout.order] as? OrderDetails
                )
                return (router.viewControllable.uiviewController, router, interactor)
            case .sell:
                let interactor = SellFlowInteractor()
                interactor.listener = SellFlowListener()
                var source: BlockchainAccount?
                if let currency = try? context.decode(blockchain.ux.asset.id, as: CryptoCurrency.self) {
                    source = coincore.cryptoTradingAccount(for: currency)
                }
                var target: TransactionTarget?
                if let currency = try? app.state.get(blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self) {
                    target = coincore.fiatAccount(for: currency)
                }

                // maybe we already have the source set
                let sellSourceAccount =  (context[blockchain.ux.transaction.source] as? AnyJSON)?.value as? BlockchainAccount

                // maybe we already have the source set
                let sellTargetAccount =  (context[blockchain.ux.transaction.source.target] as? AnyJSON)?.value as? TransactionTarget

                let router = builder.build(
                    withListener: interactor,
                    action: .sell,
                    sourceAccount: sellSourceAccount ?? source,
                    target: sellTargetAccount ?? target
                )
                return (router.viewControllable.uiviewController, router, interactor)
            case .swap:
                let interactor = SwapRootInteractor()

                // maybe we already have the source set
                let transactionSourceAccount =  (context[blockchain.ux.transaction.source] as? AnyJSON)?.value as? BlockchainAccount

                let router = builder.build(
                    withListener: interactor,
                    action: .swap,
                    sourceAccount: transactionSourceAccount,
                    target: context[blockchain.ux.transaction.source.target] as? TransactionTarget
                )
                return (router.viewControllable.uiviewController, router, interactor)
            case .deposit:
                let currency = try (try? context.decode(blockchain.ux.transaction.source.target.id, as: FiatCurrency.self)) ?? app.state.get(blockchain.user.currency.preferred.fiat.trading.currency)
                let account = try coincore.fiatAccount(for: currency).or(throw: "Cannot find account for currency \(currency)".error())
                let builder = TransactionFlowBuilder()
                let interactor = DepositRootInteractor(targetAccount: account)
                let router = builder.build(
                    withListener: interactor,
                    action: .deposit,
                    sourceAccount: nil,
                    target: account
                )
                return (router.viewControllable.uiviewController, router, interactor)
            case .withdraw:
                let currency = try (try? context.decode(blockchain.ux.transaction.source.id, as: FiatCurrency.self)) ?? app.state.get(blockchain.user.currency.preferred.fiat.trading.currency)
                let account = try coincore.fiatAccount(for: currency).or(throw: "Cannot find account for currency \(currency)".error())
                let builder = TransactionFlowBuilder()
                let interactor = WithdrawRootInteractor(sourceAccount: account)
                let router = builder.build(
                    withListener: interactor,
                    action: .deposit,
                    sourceAccount: account,
                    target: nil
                )
                return (router.viewControllable.uiviewController, router, interactor)
            default:
                return nil
            }
        } catch {
            return nil
        }
    }
}

private struct Unsupported: View {
    var body: some View {
        VStack {
            Spacer()
            Text("This is not supported yet! see \(#fileID)")
            Spacer()
        }
    }
}

@MainActor private struct SiteMapView: View {

    @BlockchainApp var app
    @Environment(\.context) var c

    var id: Tag.Reference
    var context: Tag.Context
    var siteMap: SiteMap { SiteMap(app: app) }

    init(_ event: Tag.Event, in context: Tag.Context = [:]) {
        self.id = event.key(to: context)
        self.context = context
    }

    var body: some View {
        Do {
            try siteMap.view(for: id, in: c + context)
        } catch: { error in
            ErrorView(ux: UX.Error(error: error))
        }
    }
}

private struct IfEligible<Content: View>: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @ViewBuilder var content: () -> Content

    @State var isEligible: Bool?
    @State var isVerified: Bool?

    var body: some View {
        if let isVerified {
            switch (isEligible ?? true, isVerified) {
            case (true, true): content()
            case (false, true): IneligibleView()
            case (_, false): SiteMapView(blockchain.ux.kyc.trading.unlock.more)
            }
        } else {
            BlockchainProgressView()
                .bindings {
                    subscribe($isVerified, to: blockchain.user.is.verified)
                    subscribe($isEligible, to: blockchain.api.nabu.gateway.user.products.product.is.eligible)
                }
        }
    }
}

private struct IneligibleView: View {

    struct Model: Decodable, Equatable {
        let message: String
        let learn: Learn?; struct Learn: Decodable, Equatable {
            let more: URL
        }
    }

    @State private var model: Model?
    @State private var action: AssetAction?

    var body: some View {
        ErrorView(
            ux: UX.Error(
                title: LocalizationConstants.MajorProductBlocked.title,
                message: model?.message ?? LocalizationConstants.MajorProductBlocked.defaultMessage,
                actions: (model?.learn?.more).map { url -> [UX.Action] in
                    [
                        UX.Action(title: LocalizationConstants.MajorProductBlocked.ctaButtonLearnMore, url: url),
                        UX.Action(title: LocalizationConstants.MajorProductBlocked.ok)
                    ]
                } ?? .default
            )
        )
        .bindings {
            subscribe($model, to: blockchain.api.nabu.gateway.user.products.product.ineligible)
            subscribe($action, to: blockchain.ux.transaction.id)
        }
    }
}
