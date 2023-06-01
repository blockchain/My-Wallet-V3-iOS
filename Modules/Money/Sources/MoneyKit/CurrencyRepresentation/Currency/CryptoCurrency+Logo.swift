// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

#if canImport(BlockchainComponentLibrary) && canImport(BlockchainNamespace)

import BlockchainComponentLibrary
import BlockchainNamespace

extension CryptoCurrency {

    public var color: Color {
        assetModel.spotColor.map(Color.init(hex:))
            ?? (CustodialCoinCode(rawValue: code)?.spotColor).map(Color.init(hex:))
            ?? Color(hex: ERC20Code.spotColor(code: code))
    }

    // TODO: Make use of logoResource (move it in from PlatformKit).
    @MainActor public func logo(
        size: Length = 24.pt,
        showNetworkLogo: Bool? = nil
    ) -> some View {
        CryptoCurrency.Logo(
            currency: self,
            size: size,
            showNetworkLogo: showNetworkLogo
        )
    }

    @MainActor public struct Logo: View {

        @BlockchainApp var app

        @State private var mode: AppMode?
        var currency: CryptoCurrency
        var size: Length
        var showNetworkLogo: Bool?

        var isShowingNetworkLogo: Bool {
            if let showNetworkLogo  {
                return showNetworkLogo
            }

            return mode == .pkw
        }

        public init(
            currency: CryptoCurrency,
            size: Length,
            showNetworkLogo: Bool?
        ) {
            self.currency = currency
            self.size = size
            self.showNetworkLogo = showNetworkLogo
        }

        public var body: some View {
            ZStack(alignment: .bottomTrailing) {
                AsyncMedia(url: currency.assetModel.logoPngUrl)
                if isShowingNetworkLogo, let network = currency.network(), network.nativeAsset != currency {
                    Circle()
                        .fill(Color.semantic.background)
                        .inscribed(
                            AsyncMedia(url: network.nativeAsset.logoURL)
                        )
                        .padding([.leading, .top], size.divided(by: 4))
                        .offset(x: size.divided(by: 6), y: size.divided(by: 6))
                }
            }
            .bindings {
                subscribe($mode, to: blockchain.app.mode)
            }
            .frame(width: size, height: size)
        }
    }
}

#endif
