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

@available(iOS 15, *)
public struct DexMain: ReducerProtocol {

    static let defaultCurrency: CryptoCurrency = .ethereum

    let app: AppProtocol
    let balances: () -> AnyPublisher<DelegatedCustodyBalances, Error>

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \.source, action: /Action.sourceAction) { () -> DexCell in
            DexCell(app: app, balances: balances)
        }
        Scope(state: \.destination, action: /Action.destinationAction) { () -> DexCell in
            DexCell(app: app, balances: balances)
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return balances()
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: DexMainError.failed)
                    .result()
                    .eraseToEffect(Action.onBalances)
            case .onBalances(let result):
                return .run { send async in
                    switch result {
                    case .success(let balances):
                        let positive: [DelegatedCustodyBalances.Balance] = balances.balances
                            .filter(\.balance.isPositive)
                        let supported = positive
                            .filter { balance -> Bool in
                                balance.currency == .ethereum ||
                                    balance.currency.cryptoCurrency?.isERC20 == true
                            }
                        let available = supported
                            .compactMap(\.balance.cryptoValue)
                            .map(State.Balance.init)
                        await send.send(.updateAvailableBalances(available))
                    case .failure:
                        await send.send(.updateAvailableBalances([]))
                    }
                }
            case .updateAvailableBalances(let availableBalances):
                state.availableBalances = availableBalances
                return .none
            case .destinationAction:
                return .none
            case .sourceAction:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

@available(iOS 15, *)
extension DexMain {

    public struct State: Equatable {

        public struct Balance: Equatable {
            let value: CryptoValue
            var currency: CryptoCurrency { value.currency }
        }

        var availableBalances: [Balance] {
            didSet {
                source.availableBalances = availableBalances
                destination.availableBalances = availableBalances
            }
        }
        var source: DexCell.State
        var destination: DexCell.State
        var fees: FiatValue?

        @BindableState var defaultFiatCurrency: FiatCurrency?

        public init(
            availableBalances: [Balance] = [],
            source: DexCell.State = .init(style: .source),
            destination: DexCell.State = .init(style: .destination),
            fees: FiatValue? = nil,
            defaultFiatCurrency: FiatCurrency? = nil
        ) {
            self.availableBalances = availableBalances
            self.source = source
            self.destination = destination
            self.fees = fees
            self.defaultFiatCurrency = defaultFiatCurrency
        }
    }
}

@available(iOS 15, *)
extension DexMain {
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case onBalances(Result<DelegatedCustodyBalances, DexMainError>)
        case updateAvailableBalances([State.Balance])
        case sourceAction(DexCell.Action)
        case destinationAction(DexCell.Action)
    }
}

public enum DexMainError: Error, Equatable {
    case failed
}
