// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

#if canImport(BlockchainComponentLibrary)

import BlockchainComponentLibrary
import SwiftUI

extension CryptoCurrency {

    public var color: Color {
        assetModel.spotColor.map(Color.init(hex:))
        ?? (CustodialCoinCode(rawValue: code)?.spotColor).map(Color.init(hex:))
        ?? Color(hex: ERC20Code.spotColor(code: code))
    }

    public func logo(
        size: Double = 36
    ) -> some View {
        Logo<EmptyView>(currency: self, size: size, overlay: nil)
    }

    public func logo(
        size: Double = 36,
        @ViewBuilder overlay: @escaping () -> some View
    ) -> some View {
        Logo(currency: self, size: size, overlay: overlay)
    }

    public struct Logo<Overlay: View>: View {

        var currency: CryptoCurrency
        var size: Double = 36
        var overlay: (() -> Overlay)?

        public init(
            currency: CryptoCurrency,
            size: Double = 36,
            overlay: (() -> Overlay)? = nil
        ) {
            self.currency = currency
            self.size = size
            self.overlay = overlay
        }

        public var body: some View {
            ZStack {
                AsyncMedia(url: currency.assetModel.logoPngUrl)
                    .frame(width: size - 4, height: size - 4)
                    .overlay(overlaid)
            }
            .frame(width: size, height: size)
        }

        @ViewBuilder var overlaid: some View {
            if let overlay {
                ZStack(alignment: .bottomTrailing) {
                    Color.clear
                    Circle()
                        .fill(Color.semantic.background)
                        .inscribed(overlay())
                        .frame(width: size / 3, height: size / 3)
                }
            }
        }
    }
}

#endif
