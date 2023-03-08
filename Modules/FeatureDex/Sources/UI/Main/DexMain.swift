// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Foundation
import Localization
import MoneyKit
import SwiftUI

public struct DexMain: ReducerProtocol {

    public var body: some ReducerProtocol<State, Action> {

        Reduce { _, action in
            switch action {}
        }
    }
}

extension DexMain {

    public struct State: Equatable {
        public struct Source: Equatable {
            let amount: CryptoValue?
            let amountFiat: FiatValue?
            let balance: CryptoValue?
            let fees: FiatValue?
        }

        public struct Destination: Equatable {
            let amount: CryptoValue?
            let amountFiat: FiatValue?
            let balance: CryptoValue?
        }

        var source: Source
        var destination: Destination
        var fiatCurrency: FiatCurrency
    }
}

extension DexMain {
    public enum Action: Equatable {}
}
