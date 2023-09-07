import BlockchainUI
import FeatureCheckoutDomain
import SwiftUI

public struct DepositCheckoutView: View {

    @BlockchainApp var app

    let checkout: DepositCheckout
    let confirm: (() -> Void)?

    @State private var isExternalTradingEnabled: Bool = false

    public init(checkout: DepositCheckout, confirm: (() -> Void)? = nil) {
        self.checkout = checkout
        self.confirm = confirm
    }

    public var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ScrollView {
                Group {
                    rows()
                    disclaimer()
                }
                .padding(.horizontal)
            }
            footer()
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bindings {
            subscribe($isExternalTradingEnabled, to: blockchain.app.is.external.brokerage)
        }
    }

    @ViewBuilder func rows() -> some View {
        DividedVStack(spacing: .zero) {
            from()
            to()
            if !isExternalTradingEnabled {
                fee()
            }
            settlement()
            hold()
            total()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func from() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.from)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.from)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )
    }

    @ViewBuilder func to() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.to)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.to)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )

    }

    @ViewBuilder func fee() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.blockchainFee)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.fee.displayString)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )
    }

    @State private var now: Date = Date()
    @State private var relativeDateTimeFormatter = with(RelativeDateTimeFormatter()) { formatter in
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
    }

    @ViewBuilder func settlement() -> some View {
        if let settlementDate = checkout.settlementDate {
            TableRow(
                title: {
                    Text(L10n.Label.fundsWillArrive)
                        .typography(.caption1)
                        .foregroundColor(.semantic.text)
                },
                byline: {
                    Text(relativeDateTimeFormatter.localizedString(for: settlementDate, relativeTo: now))
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                }
            )
        }
    }

    @State private var dateFormatter = with(DateFormatter()) { formatter in
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
    }

    @ViewBuilder func hold() -> some View {
        if let availableToWithdraw = checkout.availableToWithdraw {
            TableRow(
                title: {
                    Text(L10n.Label.availableToWithdraw)
                        .typography(.caption1)
                        .foregroundColor(.semantic.text)
                },
                byline: {
                    Text(availableToWithdraw)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                }
            )
        }
    }

    @ViewBuilder func total() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.total)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.total.displayString)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )
    }

    @ViewBuilder
    func disclaimer() -> some View {
        let date = DateFormatter.birthday.string(from: Date.now)

        VStack(alignment: .leading) {
            Text(rich:
                    isExternalTradingEnabled ?  L10n.Label.depositDisclaimerBakkt(date: date) :
                    L10n.Label.depositDisclaimer.interpolating(checkout.total.displayString)
            )
                .typography(.caption1)
                .foregroundColor(.semantic.text)
            if isExternalTradingEnabled {
                Image("bakkt-logo", bundle: .componentLibrary)
                    .foregroundColor(.semantic.title)
                    .padding(.top, Spacing.padding2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder func footer() -> some View {
        VStack(spacing: .zero) {
            PrimaryButton(
                title: L10n.Label.deposit(checkout.total.displayCode),
                action: confirmed
            )
        }
        .padding()
        .background(Rectangle().fill(Color.semantic.background).ignoresSafeArea())
    }

    func confirmed() {
        $app.post(event: blockchain.ux.transaction.checkout.confirmed)
        confirm?()
    }
}

struct DepositCheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        DepositCheckoutView(checkout: .preview)
    }
}
