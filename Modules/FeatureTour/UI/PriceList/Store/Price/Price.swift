// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableArchitectureExtensions
import MoneyKit
import NukeUI
import PlatformKit
import PlatformUIKit
import SwiftUI

struct Price: Equatable, Identifiable {

    var currency: CryptoCurrency
    var value: LoadingState<String> = .loading
    var deltaPercentage: LoadingState<Double> = .loading
    var id: AnyHashable = UUID()

    var title: String {
        currency.name
    }

    var abbreviation: String {
        currency.displayCode
    }

    var arrow: String {
        let delta = deltaPercentage.value ?? 0
        if delta > .zero {
            return "↑"
        } else if delta < .zero {
            return "↓"
        } else {
            return ""
        }
    }

    var formattedDelta: String {
        let delta = deltaPercentage.value ?? 0
        return "\(arrow) \(delta.string(with: 2))%"
    }
}
