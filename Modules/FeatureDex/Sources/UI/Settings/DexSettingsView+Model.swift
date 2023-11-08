// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import MoneyKit
import SwiftUI

extension DexSettingsView {
    struct Model {

        struct Slippage: Identifiable, Hashable {
            var id: String { label }

            let value: Double
            let label: String

            init(value: Double) {
                self.value = value
                self.label = value.formatted(.percent)
            }
        }

        let slippageModels: [Slippage] = allowedSlippages.map(Slippage.init(value:))

        var selected: Slippage
        var expressMode: Bool
        var gasOnDestination: Bool

        var expressModeAllowed: Bool = false
        var gasOnDestinationAllowed: Bool = false

        init(
            selected: Slippage,
            expressMode: Bool,
            gasOnDestination: Bool
        ) {
            self.selected = selected
            self.expressMode = expressMode
            self.gasOnDestination = gasOnDestination
        }
    }
}

private let allowedSlippages: [Double] = [0.002, 0.005, 0.01, 0.03]
let defaultSlippage: Double = 0.005
