import BlockchainUI
import SwiftUI

public struct YouDontHaveAnyBalanceView: View {

    @BlockchainApp var app
    @State private var currency: FiatCurrency = .USD

    public init() {}

    public var body: some View {
        VStack(spacing: 16.pt) {
            VStack(spacing: 24.pt) {
                currency.logo(size: 88.pt)
                VStack(spacing: 8.pt) {
                    Text(L10n.youDontHaveAnyBalance)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(L10n.fundYourAccount)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                }
                .multilineTextAlignment(.center)
            }
            PrimaryButton(
                title: L10n.deposit.interpolating(currency.displayCode),
                action: {
                    $app.post(event: blockchain.ux.user.custodial.dashboard.no.fiat.balance.deposit.paragraph.button.primary.tap)
                }
            )
            .padding(.top, 8.pt)
        }
        .padding(.top, 40.pt)
        .overlay(
            IconButton(
                icon: .navigationCloseButton(),
                action: { $app.post(event: blockchain.ux.user.custodial.dashboard.no.fiat.balance.article.plain.navigation.bar.button.close.tap) }
            ),
            alignment: .topTrailing
        )
        .padding(.top)
        .padding(.horizontal)
        .background(Color.semantic.background)
        .batch {
            set(blockchain.ux.user.custodial.dashboard.no.fiat.balance.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            set(blockchain.ux.user.custodial.dashboard.no.fiat.balance.deposit.paragraph.button.primary.tap.then.close, to: true)
            set(blockchain.ux.user.custodial.dashboard.no.fiat.balance.deposit.paragraph.button.primary.tap.then.emit, to: blockchain.ux.user.custodial.dashboard.no.fiat.balance.deposit.action)
            set(blockchain.ux.user.custodial.dashboard.no.fiat.balance.deposit.action.then.enter.into, to: blockchain.ux.transaction["deposit"])
        }
        .bindings {
            subscribe($currency, to: blockchain.user.currency.preferred.fiat.trading.currency)
        }
    }
}

struct YouDontHaveAnyBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        YouDontHaveAnyBalanceView()
            .app(App.preview)
    }
}
