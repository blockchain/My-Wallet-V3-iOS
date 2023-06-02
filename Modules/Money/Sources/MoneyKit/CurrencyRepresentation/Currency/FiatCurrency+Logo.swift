// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

#if canImport(BlockchainComponentLibrary)

import BlockchainComponentLibrary
import BlockchainNamespace

extension CurrencyType {

    @ViewBuilder @MainActor public func logo(
        size: Length = 24.pt,
        showNetworkLogo: Bool? = nil
    ) -> some View {
        switch self {
        case .fiat(let fiat):
            fiat.logo(size: size)
        case .crypto(let crypto):
            crypto.logo(size: size,
                        showNetworkLogo: showNetworkLogo)
        }
    }
}

extension FiatCurrency {

    @MainActor public func logo(
        size: Length = 24.pt
    ) -> some View {
        FiatCurrency.Logo(currency: self, size: size)
    }

    @MainActor public struct Logo: View {

        var currency: FiatCurrency
        var size: Length

        public init(currency: FiatCurrency, size: Length) {
            self.currency = currency
            self.size = size
        }

        public var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.semantic.fiatGreen)
                .frame(width: size, height: size)
                .overlay(
                    Text(currency.displaySymbol)
                        .minimumScaleFactor(0.6)
                        .padding(2)
                        .typography(.paragraph1.bold())
                        .foregroundColor(.semantic.light)
                )
        }
    }
}

#endif
