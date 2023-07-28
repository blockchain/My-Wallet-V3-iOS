// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

#if canImport(BlockchainComponentLibrary)

import BlockchainComponentLibrary
import BlockchainNamespace

extension FiatCurrency {

    public func logo(
        size: Length = 24.pt
    ) -> some View {
        FiatCurrency.Logo(currency: self, size: size)
    }

    public struct Logo: View {

        var currency: FiatCurrency
        var size: Length

        public init(currency: FiatCurrency, size: Length) {
            self.currency = currency
            self.size = size
        }

        @ViewBuilder
        public var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.semantic.fiatGreen)
                .frame(width: size, height: size)
                .overlay(
                    currency.logoResource.image
                        .padding(2)
                        .foregroundColor(.semantic.light)
                )
        }
    }
}

#endif
