// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureTransactionDomain
import PlatformUIKit
import SwiftUI
import UIComponentsKit

public enum CryptoCurrencyQuoteAction: Equatable {
    case select(CryptoCurrencyQuote)
}

struct CryptoCurrencyQuoteCell: View {

    let store: Store<CryptoCurrencyQuote, CryptoCurrencyQuoteAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.semantic.background)
                    .contentShape(Rectangle())
                VStack {
                    HStack(spacing: 16) {
                        if let logoResource = viewStore.cryptoCurrency.logoResource.resource {
                            switch logoResource {
                            case .image(let image):
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32.0, height: 32.0)
                            case .url(let url):
                                ImageResourceView(url: url)
                                    .scaledToFit()
                                    .frame(width: 32.0, height: 32.0)
                            }
                        }
                        VStack(alignment: .leading, spacing: .zero) {
                            Text(viewStore.cryptoCurrency.name)
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.text)
                            HStack {
                                Text(viewStore.formattedQuote)
                                    .typography(.paragraph1)
                                    .foregroundColor(.semantic.text)
                                Text(viewStore.formattedPriceChange)
                                    .foregroundColorBasedOnPercentageChange(viewStore.priceChange)
                                    .typography(.paragraph1)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8.0, height: 12.0)
                            .foregroundColor(.semantic.text)
                    }
                    .padding([.top, .bottom], 10)
                }
            }
            .onTapGesture {
                viewStore.send(.select(viewStore.state))
            }
        }
    }
}
