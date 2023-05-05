// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import DIKit
import Errors
import FeatureDexData
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
                let balances = dexService.balances()
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onBalances)
                let supportedTokens = dexService.supportedTokens()
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onSupportedTokens)
                return .merge(balances, supportedTokens)

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
            case .didTapPreview:
                return .none
            case .didTapAllowance:
                return .none

                // Supported Tokens
            case .onSupportedTokens(let result):
                switch result {
                case .success(let tokens):
                    state.destination.supportedTokens = tokens
                case .failure:
                    break
                }
                return .none

                // Balances
            case .onBalances(let result):
                switch result {
                case .success(let balances):
                    return EffectTask(value: .updateAvailableBalances(balances))
                case .failure:
                    return EffectTask(value: .updateAvailableBalances([]))
                }
            case .updateAvailableBalances(let availableBalances):
                state.availableBalances = availableBalances
                return .none

                // Quote
            case .refreshQuote:
                return .merge(
                    .cancel(id: CancellationID.Allowance.Fetch.self),
                    fetchQuote(with: state)
                        .receive(on: mainQueue)
                        .eraseToEffect(Action.onQuote)
                        .cancellable(id: CancellationID.Quote.Fetch.self, cancelInFlight: true)
                )
            case .onQuote(let result):
                _onQuote(with: &state, update: result)
                return EffectTask(value: .refreshAllowance)

                // Allowance
            case .refreshAllowance:
                guard let quote = state.quote?.success else {
                    return .none
                }
                return dexService
                    .allowance(app: app, currency: quote.sellAmount.currency)
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onAllowance)
                    .cancellable(id: CancellationID.Allowance.Fetch.self, cancelInFlight: true)
            case .onAllowance(let result):
                switch result {
                case .success(let allowance):
                    print("onAllowance: success: \(allowance)")
                    return EffectTask(value: .updateAllowance(allowance))
                case .failure(let error):
                    print("onAllowance: error: \(error)")
                    return EffectTask(value: .updateAllowance(nil))
                }
            case .updateAllowance(let allowance):
                state.allowance.result = allowance
                return .none

                // Source action
            case .sourceAction(.binding(\.$inputText)):
                _onQuote(with: &state, update: nil)
                return EffectTask.merge(
                    .cancel(id: CancellationID.Allowance.Fetch.self),
                    .cancel(id: CancellationID.Quote.Fetch.self),
                    EffectTask(value: .refreshQuote)
                        .debounce(
                            id: CancellationID.Quote.Debounce.self,
                            for: .milliseconds(500),
                            scheduler: mainQueue
                        )
                )

            case .sourceAction(.didSelectCurrency):
                _onQuote(with: &state, update: nil)
                return .cancel(id: CancellationID.Quote.Fetch.self)
            case .sourceAction:
                return .none

                // Destination action
            case .destinationAction(.didSelectCurrency):
                _onQuote(with: &state, update: nil)
                return .cancel(id: CancellationID.Quote.Fetch.self)
            case .destinationAction:
                return .none

                // Binding
            case .binding(\.$defaultFiatCurrency):
                print("binding(defaultFiatCurrency): \(String(describing: state.defaultFiatCurrency))")
                return .none
            case .binding(\.$slippage):
                print("binding(slippage): \(state.slippage)")
                return .none
            case .binding:
                return .none
            }
        }
    }
}

extension DexMain {

    func _onQuote(with state: inout State, update quote: Result<DexQuoteOutput, UX.Error>?) {
        if let old = state.quote?.success, old.sellAmount.currency != quote?.success?.sellAmount.currency {
            state.allowance.result = nil
            state.allowance.transactionHash = nil
        }
        state.quote = quote
    }

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
    case lowBalance
    case balancesFailed
}

extension DexMain {
    enum CancellationID {
        enum Quote {
            enum Debounce {}
            enum Fetch {}
        }
        enum Allowance {
            enum Fetch {}
        }
    }
}

@inlinable func print(_ message: String) {
    Swift.print("🐚 \(message)")
}
