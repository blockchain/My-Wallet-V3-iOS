// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureDexDomain
import MoneyKit

extension DexMain {

    public struct State: Equatable {

        var availableBalances: [DexBalance] {
            didSet {
                source.availableBalances = availableBalances
                destination.availableBalances = availableBalances
            }
        }

        var source: DexCell.State
        var destination: DexCell.State
        var quote: DexQuoteOutput?

        @BindingState var slippage: Double = defaultSlippage
        @BindingState var defaultFiatCurrency: FiatCurrency?

        public init(
            availableBalances: [DexBalance] = [],
            source: DexCell.State = .init(style: .source),
            destination: DexCell.State = .init(style: .destination),
            quote: DexQuoteOutput? = nil,
            defaultFiatCurrency: FiatCurrency? = nil
        ) {
            self.availableBalances = availableBalances
            self.source = source
            self.destination = destination
            self.quote = quote
            self.defaultFiatCurrency = defaultFiatCurrency
        }
    }
}
