// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import Foundation
import Localization
import MoneyKit
import SwiftUI

public struct DexMain: ReducerProtocol {

    let balances: () -> AnyPublisher<DelegatedCustodyBalances, Error>

    public var body: some ReducerProtocol<State, Action> {

        Reduce { state, action in
            switch action {
            case .onAppear:
                return balances()
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: DexMainError.failed)
                    .result()
                    .eraseToEffect(Action.onBalances)
            case .onBalances(.success(let balances)):
                state.noBalance = !balances.hasAnyBalance
                return .none
            case .onBalances(.failure):
                state.noBalance = true
                return .none
            }
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

        var noBalance: Bool = true
        var source: Source
        var destination: Destination?
        var fiatCurrency: FiatCurrency
    }
}

extension DexMain {
    public enum Action: Equatable {
        case onAppear
        case onBalances(Result<DelegatedCustodyBalances, DexMainError>)
    }
}

public enum DexMainError: Error, Equatable {
    case failed
}
