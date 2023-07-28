// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

#if canImport(BlockchainComponentLibrary)

import BlockchainComponentLibrary
import BlockchainNamespace

extension CurrencyType {

    @ViewBuilder
    public func logo(
        size: Length = 24.pt,
        showNetworkLogo: Bool? = nil
    ) -> some View {
        switch self {
        case .fiat(let fiat):
            fiat.logo(size: size)
        case .crypto(let crypto):
            crypto.logo(size: size, showNetworkLogo: showNetworkLogo)
        }
    }
}

#endif
