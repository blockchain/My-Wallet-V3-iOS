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
    @Dependency(\.dexService) var dexService
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.app) var app

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \.source, action: /Action.sourceAction) {
            DexCell()
        }
        Scope(state: \.destination, action: /Action.destinationAction) {
            DexCell()
        }
        Scope(state: \.networkPickerState, action: /Action.networkSelectionAction) {
            NetworkPicker()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                let balances = dexService.balancesStream()
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onBalances)
                    .cancellable(id: CancellationID.balances, cancelInFlight: true)

                var supportedTokens = EffectTask<DexMain.Action>.none
                if state.destination.supportedTokens.isEmpty {
                    supportedTokens = dexService.supportedTokens()
                        .receive(on: mainQueue)
                        .eraseToEffect(Action.onSupportedTokens)
                }

                var availableNetworks = EffectTask<DexMain.Action>.none
                if state.availableNetworks.isEmpty {
                    availableNetworks = dexService
                        .availableNetworks()
                        .receive(on: mainQueue)
                        .eraseToEffect(Action.onAvailableNetworksFetched)
                }

                return .merge(balances, supportedTokens, availableNetworks)

            case .didTapSettings:
                _dismissKeyboard(&state)
                let settings = blockchain.ux.currency.exchange.dex.settings
                let detents = blockchain.ui.type.action.then.enter.into.detents
                app.post(
                    event: settings.tap,
                    context: [
                        settings.sheet.slippage: state.slippage,
                        detents: [detents.automatic.dimension]
                    ]
                )
                return .none

            case .didTapPreview:
                _dismissKeyboard(&state)
                state.confirmation = DexConfirmation.State(
                    quote: state.quote?.success,
                    balances: state.availableBalances ?? []
                )
                state.isConfirmationShown = true
                return .none
            case .didTapAllowance:
                _dismissKeyboard(&state)
                let allowance = blockchain.ux.currency.exchange.dex.allowance
                let detents = blockchain.ui.type.action.then.enter.into.detents
                app.post(
                    event: allowance.tap,
                    context: [
                        allowance.sheet.currency: state.source.currency!.code,
                        detents: [detents.automatic.dimension]
                    ]
                )
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
                    return .none
                }
            case .updateAvailableBalances(let availableBalances):
                state.availableBalances = availableBalances
                return .none

                // Quote
            case .refreshQuote:
                guard let preInput = quotePreInput(with: state) else {
                    return .cancel(id: CancellationID.allowanceFetch)
                }
                state.quoteFetching = true
                return .merge(
                    .cancel(id: CancellationID.allowanceFetch),
                    fetchQuote(with: preInput)
                        .receive(on: mainQueue)
                        .eraseToEffect(Action.onQuote)
                        .cancellable(id: CancellationID.quoteFetch, cancelInFlight: true)
                )

            case .onQuote(let result):
                if sellCurrencyChanged(state: state, newQuoteResult: result) {
                    state.allowance.result = nil
                    state.allowance.transactionHash = nil
                }
                state.quoteFetching = false
                state.quote = result
                state.confirmation?.newQuote = DexConfirmation.State.Quote(quote: result.success)
                return EffectTask(value: .refreshAllowance)

                // Allowance
            case .refreshAllowance:
                guard let quote = state.quote?.success, state.allowance.result != .ok else {
                    return .none
                }
                return dexService
                    .allowance(app: app, currency: quote.sellAmount.currency)
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onAllowance)
                    .cancellable(id: CancellationID.allowanceFetch, cancelInFlight: true)

            case .onAllowance(let result):
                switch result {
                case .success(let allowance):
                    return EffectTask(value: .updateAllowance(allowance))
                case .failure:
                    return EffectTask(value: .updateAllowance(nil))
                }
            case .updateAllowance(let allowance):
                let willRefresh = allowance == .ok
                    && state.allowance.result != .ok
                    && state.quote?.success?.isValidated != true
                state.allowance.result = allowance
                if willRefresh {
                    return EffectTask(value: .refreshQuote)
                        .debounce(
                            id: CancellationID.quoteDebounce,
                            for: .milliseconds(100),
                            scheduler: mainQueue
                        )
                }
                return .none

            case .onAvailableNetworksFetched(.success(let networks)):
                let wasEmpty = state.availableNetworks.isEmpty
                state.availableNetworks = networks
                guard wasEmpty else {
                    return .none
                }
                state.currentNetwork = preselectNetwork(from: networks)
                return .none

            case .onAvailableNetworksFetched(.failure):
                return .none

            case .onTransaction(let result, let quote):
                switch result {
                case .success(let transactionId):
                    let dialog = dexSuccessDialog(quote: quote, transactionId: transactionId)
                    state.confirmation?.pendingTransaction?.status = .success(dialog, quote.buyAmount.amount.currency)
                case .failure(let error):
                    state.confirmation?.pendingTransaction?.status = .error(error)
                }
                clearAfterTransaction(with: &state)
                return .none

                // Confirmation Action
            case .confirmationAction(.confirm):
                if let quote = state.quote?.success {
                    let dialog = dexInProgressDialog(quote: quote)
                    let newState = PendingTransaction.State(
                        currency: quote.sellAmount.currency,
                        status: .inProgress(dialog)
                    )
                    state.confirmation?.pendingTransaction = newState
                    return .merge(
                        .cancel(id: CancellationID.quoteFetch),
                        dexService
                            .executeTransaction(quote: quote)
                            .receive(on: mainQueue)
                            .eraseToEffect { output in
                                Action.onTransaction(output, quote)
                            }
                    )
                }
                return .cancel(id: CancellationID.quoteFetch)
            case .confirmationAction:
                return .none

                // Source action
            case .sourceAction(.onTapBalance), .sourceAction(.binding(\.$inputText)):
                clearDuringTyping(with: &state)
                return EffectTask.merge(
                    .cancel(id: CancellationID.allowanceFetch),
                    .cancel(id: CancellationID.quoteFetch),
                    EffectTask(value: .refreshQuote)
                        .debounce(
                            id: CancellationID.quoteDebounce,
                            for: .milliseconds(500),
                            scheduler: mainQueue
                        )
                )

            case .sourceAction(.didSelectCurrency(let balance)):
                state.destination.bannedToken = balance.currency
                clearAfterCurrencyChange(with: &state)
                return .cancel(id: CancellationID.quoteFetch)
            case .sourceAction:
                return .none
            case .dismissKeyboard:
                _dismissKeyboard(&state)
                return .none

                // Network Picker Action
            case .networkSelectionAction(.onNetworkSelected(let network)):
                state.currentNetwork = network
                return .none

            case .networkSelectionAction(.onDismiss):
                return .none

            case .networkSelectionAction:
                return .none

                // Destination action
            case .destinationAction(.didSelectCurrency):
                clearAfterCurrencyChange(with: &state)
                return .merge(
                    .cancel(id: CancellationID.allowanceFetch),
                    .cancel(id: CancellationID.quoteFetch),
                    EffectTask(value: .refreshQuote)
                        .debounce(
                            id: CancellationID.quoteDebounce,
                            for: .milliseconds(100),
                            scheduler: mainQueue
                        )
                )
            case .destinationAction:
                return .none
            case .onSelectNetworkTapped:
                let networkPicker = blockchain.ux.currency.exchange.dex.network.picker
                let detents = blockchain.ui.type.action.then.enter.into.detents
                app.post(
                    event: networkPicker.tap,
                    context: [
                        blockchain.ux.currency.exchange.dex.network.picker.sheet.selected.network: state.currentSelectedNetworkTicker,
                        detents: [detents.automatic.dimension]
                    ]
                )
                return .none

            case .onInegibilityLearnMoreTap:
                return .run { send in
                    let url = try? await app.get(blockchain.api.nabu.gateway.user.products.product["DEX"].ineligible.learn.more) as URL
                    let fallbackUrl = try? await app.get(blockchain.app.configuration.asset.dex.ineligibility.learn.more.url) as URL


                    try? await app.set(blockchain.ux.currency.exchange.dex.not.eligible.learn.more.tap.then.launch.url, to: url ?? fallbackUrl)
                    app.post(event: blockchain.ux.currency.exchange.dex.not.eligible.learn.more.tap)

                }

                // Binding
            case .binding(\.allowance.$transactionHash):
                guard let quote = state.quote?.success else {
                    return .none
                }
                return dexService
                    .allowancePoll(app: app, currency: quote.sellAmount.currency)
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onAllowance)
                    .cancellable(id: CancellationID.allowanceFetch, cancelInFlight: true)
            case .binding(\.$defaultFiatCurrency):
                return .none
            case .binding(\.$slippage):
                return .none

            case .binding(\.$currentSelectedNetworkTicker):
                state.currentNetwork = state.availableNetworks.first(where: { $0.networkConfig.networkTicker == state.currentSelectedNetworkTicker })
                return .none
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.confirmation, action: /Action.confirmationAction) {
            DexConfirmation(app: app)
        }
    }
}

extension DexConfirmation.State.Quote {
    init?(quote: DexQuoteOutput?) {
        guard let quote else {
            return nil
        }
        guard let slippage = Double(quote.slippage) else {
            return nil
        }
        self = DexConfirmation.State.Quote(
            enoughBalance: true,
            from: DexConfirmation.State.Target(value: quote.sellAmount),
            minimumReceivedAmount: quote.buyAmount.minimum!,
            networkFee: quote.networkFee,
            productFee: quote.productFee,
            slippage: slippage,
            to: DexConfirmation.State.Target(value: quote.buyAmount.amount)
        )
    }
}

extension DexConfirmation.State {
    init?(quote: DexQuoteOutput?, balances: [DexBalance]) {
        guard let quote = DexConfirmation.State.Quote(quote: quote) else {
            return nil
        }
        self.init(quote: quote, balances: balances)
    }
}

extension DexMain {

    private func sellCurrencyChanged(state: DexMain.State, newQuoteResult: Result<DexQuoteOutput, UX.Error>) -> Bool {
        let oldSellCurrency = state.quote?.success?.sellAmount.currency
        let newSellCurrency = newQuoteResult.success?.sellAmount.currency
        if let oldSellCurrency, oldSellCurrency != newSellCurrency {
            return true
        }
        return false
    }

    private func clearAfterTransaction(with state: inout State) {
        _dismissKeyboard(&state)
        state.quoteFetching = false
        state.quote = nil
        dexCellClear(state: &state.destination)
        state.source.inputText = ""
    }

    private func clearAfterCurrencyChange(with state: inout State) {
        _dismissKeyboard(&state)
        state.quoteFetching = false
        state.allowance.result = nil
        state.allowance.transactionHash = nil
        state.quote = nil
        state.confirmation?.newQuote = DexConfirmation.State.Quote(quote: nil)
    }

    private func clearDuringTyping(with state: inout State) {
        state.quoteFetching = false
        state.quote = nil
        state.confirmation?.newQuote = DexConfirmation.State.Quote(quote: nil)
    }

    private func _dismissKeyboard(_ state: inout DexMain.State) {
        state.source.textFieldIsFocused = false
        state.destination.textFieldIsFocused = false
    }

    func fetchQuote(with input: QuotePreInput) -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never> {
        guard !input.isLowBalance else {
            let error = DexUXError.insufficientFunds(input.amount.currency)
            return .just(.failure(error))
        }
        return quoteInput(with: input)
            .mapError(UX.Error.init(error:))
            .result()
            .flatMap { input -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never> in
                switch input {
                case .success(let input):
                    return dexService.quote(input)
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
            .eraseToAnyPublisher()
    }

    struct QuotePreInput {
        var amount: CryptoValue
        var destination: CryptoCurrency
        var skipValidation: Bool
        var slippage: Double
        var isLowBalance: Bool
    }

    func quotePreInput(with state: State) -> QuotePreInput? {
        guard let source = state.source.amount, source.isPositive else {
            return nil
        }
        guard let destination = state.destination.currency else {
            return nil
        }
        let skipValidation = state.allowance.result != .ok && !source.currency.isCoin
        let value = QuotePreInput(
            amount: source,
            destination: destination,
            skipValidation: skipValidation,
            slippage: state.slippage,
            isLowBalance: state.isLowBalance
        )
        return value
    }

    private func quoteInput(with input: QuotePreInput) -> AnyPublisher<DexQuoteInput, Error> {
        dexService
            .receiveAddressProvider(app, input.amount.currency)
            .map { takerAddress in
                DexQuoteInput(
                    amount: input.amount,
                    destination: input.destination,
                    skipValidation: input.skipValidation,
                    slippage: input.slippage,
                    takerAddress: takerAddress
                )
            }
            .eraseToAnyPublisher()
    }
}

extension DexMain {
    enum CancellationID {
        case balances
        case quoteDebounce
        case quoteFetch
        case allowanceFetch
    }
}

private func dexInProgressDialog(quote: DexQuoteOutput) -> DexDialog {
    DexDialog(
        title: String(
            format: L10n.Execution.InProgress.title,
            quote.sellAmount.displayCode,
            quote.buyAmount.amount.displayCode
        ),
        status: .pending
    )
}

private func dexSuccessDialog(
    quote: DexQuoteOutput,
    transactionId: String
) -> DexDialog {
    DexDialog(
        title: String(
            format: L10n.Execution.Success.title,
            quote.sellAmount.displayCode,
            quote.buyAmount.amount.displayCode
        ),
        message: L10n.Execution.Success.body,
        buttons: [
            DexDialog.Button(
                title: "View on Explorer",
                action: .openURL(explorerURL(quote: quote, transactionId: transactionId))
            ),
            DexDialog.Button(
                title: "Done",
                action: .dismiss
            )
        ],
        status: .pending
    )
}

private func explorerURL(
    quote: DexQuoteOutput,
    transactionId: String
) -> URL? {
    let service = EnabledCurrenciesService.default
    guard let network = service.network(for: quote.sellAmount.currency) else {
        return nil
    }
    return URL(string: network.networkConfig.explorerUrl + "/" + transactionId)
}

private func preselectNetwork(from networks: [EVMNetwork]) -> EVMNetwork? {
    networks.first(where: { $0.networkConfig == .ethereum }) ?? networks.first
}
