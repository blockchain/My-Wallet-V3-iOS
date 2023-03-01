// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct TopMoverView: View {
    let priceRowData: PricesRowData

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
            VStack(alignment: .leading, spacing: 8.pt) {
                HStack {
                    AsyncMedia(
                        url: priceRowData.url
                    )
                    .resizingMode(.aspectFit)
                    .frame(width: 24.pt, height: 24.pt)
                    Text(priceRowData.currency.code)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.title)
                }
                .padding(.bottom, 4.pt)
                Text(priceRowData.priceChangeString ?? "")
                    .typography(.body2)
                    .foregroundColor(priceRowData.priceChangeColor)

                Text(priceRowData.price?.toDisplayString(includeSymbol: true) ?? "")
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
            }
            .padding(Spacing.padding2.pt)
        }
        .aspectRatio(4 / 3, contentMode: .fit)
    }
}

struct TopMoverView_Previews: PreviewProvider {
    static var previews: some View {
        let data = PricesRowData(currency: .bitcoin, delta: 30.5, isFavorite: false, isTradable: false, networkName: nil, price: .init(storeAmount: 30, currency: .fiat(.EUR)))

        TopMoverView(priceRowData: data)
    }
}
