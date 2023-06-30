// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureTopMoversCryptoDomain
import SwiftUI

struct TopMoverView: View {
    @BlockchainApp var app
    @Environment(\.scheduler) var scheduler

    let presenter: TopMoversPresenter
    let topMover: TopMoverInfo

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
            VStack(alignment: .leading, spacing: 8.pt) {
                HStack {
                    AsyncMedia(
                        url: topMover.currency.logoURL
                    )
                    .resizingMode(.aspectFit)
                    .frame(width: 24.pt, height: 24.pt)
                    Text(topMover.currency.code)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.title)
                }
                .padding(.bottom, 4.pt)
                Text(topMover.priceChangeString ?? "")
                    .typography(.body2)
                    .truncationMode(.middle)
                    .foregroundColor(topMover.priceChangeColor)

                Text(topMover.price.toDisplayString(includeSymbol: true))
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
            }
            .padding(Spacing.padding2.pt)
        }
        .aspectRatio(4 / 3, contentMode: .fit)
        .onTapGesture {
            $app.post(event: presenter.action.paragraph.card.tap, context: [blockchain.ux.asset.id: topMover.currency.code])
        }
        .batch {
            if presenter == .accountPicker {
                // we need to select the token and continue the buy flow
                set(presenter.action.paragraph.card.tap.then.navigate.to, to: blockchain.ux.transaction["buy"])
            } else {
                // we need to show coin view
                set(presenter.action.paragraph.card.tap.then.enter.into, to: blockchain.ux.asset)
            }
        }
    }
}

extension TopMoverInfo {
    var priceChangeString: String? {
        guard let delta else {
            return nil
        }
        var arrowString: String {
            if delta.isZero {
                return ""
            }
            if delta.isSignMinus {
                return "↓"
            }

            return "↑"
        }

        let deltaFormatted = delta.formatted(.percent.precision(.fractionLength(2)))
        return "\(arrowString) \(deltaFormatted)"
    }

    var priceChangeColor: Color? {
        guard let delta else {
            return nil
        }
        if delta.isSignMinus {
            return Color.WalletSemantic.pink
        } else if delta.isZero {
            return Color.WalletSemantic.body
        } else {
            return Color.WalletSemantic.success
        }
    }
}

struct TopMoverView_Previews: PreviewProvider {
    static var previews: some View {
        let topMover = TopMoverInfo(currency: .bitcoin, delta: 30, price: .one(currency: .EUR))

        TopMoverView(
            presenter: .accountPicker,
            topMover: topMover
        )
    }
}
