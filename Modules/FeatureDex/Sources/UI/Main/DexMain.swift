// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import DIKit
import Errors
import FeatureDexDomain
import Foundation
import MoneyKit
import SwiftUI

public struct DexMain: ReducerProtocol {

    static let defaultCurrency: CryptoCurrency = .ethereum

    @Dependency(\.dexService) var dexService
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
    let app: AppProtocol

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \.source, action: /Action.sourceAction) {
            DexCell()
        }
        Scope(state: \.destination, action: /Action.destinationAction) {
            DexCell()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return dexService.balances()
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onBalances)
            case .onBalances(.success(let balances)):
                return EffectTask(value: .updateAvailableBalances(balances))
            case .onBalances(.failure):
                return EffectTask(value: .updateAvailableBalances([]))
            case .didTapSettings:
                let settings = blockchain.ux.currency.exchange.dex.settings
                app.post(
                    event: settings.tap,
                    context: [
                        settings.sheet.slippage: state.slippage,
                        blockchain.ui.type.action.then.enter.into.detents: [
                            blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                        ]
                    ]
                )
                return .none
            case .updateAvailableBalances(let availableBalances):
                state.availableBalances = availableBalances
                return .none
            case .binding(\.$defaultFiatCurrency):
                print("🏓 binding(defaultFiatCurrency): \(String(describing: state.defaultFiatCurrency))")
                return .none
            case .binding(\.$slippage):
                print("🏓 binding(slippage): \(state.slippage)")
                return .none
            case .onQuote(.success(let quote)):
                print("🏓 onQuote: success: \(quote)")
                return EffectTask(value: .updateQuote(quote))
            case .onQuote(.failure(let error)):
                print("🏓 onQuote: error: \(error)")
                state.error = error
                return EffectTask(value: .updateQuote(nil))
            case .refreshQuote:
                return fetchQuote(with: state)
                    .receive(on: mainQueue)
                    .eraseToEffect { output in
                        Action.onQuote(output)
                    }
                    .cancellable(id: CancellationID.OnQuote.self, cancelInFlight: true)
            case .updateQuote(let quote):
                state.quote = quote
                state.destination.overrideAmount = quote?.buyAmount.amount
                return .none
            case .sourceAction(.binding(\.$inputText)):
                return EffectTask.merge(
                    .cancel(id: CancellationID.OnQuote.self),
                    EffectTask(value: .updateQuote(nil)),
                    EffectTask(value: .refreshQuote)
                        .debounce(
                            id: CancellationID.RefreshQuote.self,
                            for: .milliseconds(500),
                            scheduler: mainQueue
                        )
                )
            case .sourceAction(.didSelectCurrency):
                return .merge(
                    .cancel(id: CancellationID.OnQuote.self),
                    EffectTask(value: .updateQuote(nil))
                )
            case .destinationAction(.didSelectCurrency):
                return .merge(
                    .cancel(id: CancellationID.OnQuote.self),
                    EffectTask(value: .updateQuote(nil))
                )
            case .sourceAction:
                return .none
            case .destinationAction:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

extension DexMain {
    func fetchQuote(with state: State) -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never> {
        quoteInput(with: state)
            .flatMap { input -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never> in
                guard let input else {
                    return .just(.failure(UX.Error(error: QuoteError.notReady)))
                }
                return dexService.quote(input)
            }
            .eraseToAnyPublisher()
    }

    private func quoteInput(with state: State) -> AnyPublisher<DexQuoteInput?, Never> {
        guard let amount = state.source.amount else {
            return .just(nil)
        }
        guard let destination = state.destination.currency else {
            return .just(nil)
        }
        return dexService.receiveAddressProvider(app, amount.currency)
            .map { takerAddress in
                DexQuoteInput(
                    amount: amount,
                    destination: destination,
                    skipValidation: true,
                    slippage: state.slippage,
                    takerAddress: takerAddress
                )
            }
            .optional()
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}

public enum DexMainError: Error, Equatable {
    case balancesFailed
}

extension DexMain {
    enum CancellationID {
        enum RefreshQuote {}
        enum OnQuote {}
    }
}
