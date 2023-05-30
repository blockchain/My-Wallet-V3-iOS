import BlockchainUI
import DIKit
import FeatureCheckoutUI
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
            TransactionView()
                .ignoresSafeArea()
                .navigationBarHidden(true)
        case blockchain.ux.transaction.disclaimer:
            let product = try ref[blockchain.ux.transaction.id].decode(AssetAction.self).earnProduct.decode(EarnProduct.self)
            EarnConsiderationsView(pages: product.considerations)
                .context([blockchain.user.earn.product.id: product.value])
        case blockchain.ux.transaction[AssetAction.buy].select.target:
            BuyEntryView()
        case blockchain.ux.transaction[AssetAction.sell].select.source:
            SellEntryView()
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
                let router = builder.build(
                    withListener: interactor,
                    action: .sell,
                    sourceAccount: context[blockchain.ux.transaction.source] as? BlockchainAccount ?? source,
                    target: context[blockchain.ux.transaction.source.target] as? TransactionTarget ?? target
                )
                return (router.viewControllable.uiviewController, router, interactor)
            case .swap:
                let interactor = SwapRootInteractor()
                var source: BlockchainAccount?
                if let currency = try? context.decode(blockchain.ux.asset.id, as: CryptoCurrency.self) {
                    source = coincore.cryptoTradingAccount(for: currency)
                }
                let router = builder.build(
                    withListener: interactor,
                    action: .swap,
                    sourceAccount: context[blockchain.ux.transaction.source] as? BlockchainAccount ?? source,
                    target: context[blockchain.ux.transaction.source.target] as? TransactionTarget
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

struct Unsupported: View {
    var body: some View {
        VStack {
            Spacer()
            Text("This is not supported yet! see \(#fileID)")
            Spacer()
        }
    }
}
