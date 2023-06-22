// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import ComposableArchitecture
import FeatureDexDomain
import MoneyKit

extension DexMain {

    public struct State: Equatable {

        var availableBalances: [DexBalance]? {
            didSet {
                source.availableBalances = availableBalances ?? []
                destination.availableBalances = availableBalances ?? []
            }
        }

        var isLoadingState: Bool {
            availableBalances == nil
        }

        var isEmptyState: Bool {
            availableBalances?.isEmpty == true
        }

        var availableNetworks: [EVMNetwork] = [] {
            didSet {
                networkPickerState.available = availableNetworks
            }
        }

        var currentNetwork: EVMNetwork? {
            didSet {
                networkPickerState.current = currentNetwork
                source.currentNetwork = currentNetwork
                destination.currentNetwork = currentNetwork
            }
        }

        var source: DexCell.State
        var destination: DexCell.State
        var networkPickerState: NetworkPicker.State = NetworkPicker.State()

        var quoteFetching: Bool = false
        var quote: Result<DexQuoteOutput, UX.Error>? {
            didSet {
                destination.overrideAmount = quote?.success?.buyAmount.amount
            }
        }

        var allowance: Allowance
        var confirmation: DexConfirmation.State?

        @BindingState var networkTransactionInProgressCard: Bool = false
        @BindingState var slippage: Double = defaultSlippage
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var isConfirmationShown: Bool = false
        @BindingState var isSelectNetworkShown: Bool = false

        init(
            availableBalances: [DexBalance]? = nil,
            source: DexCell.State = .init(style: .source),
            destination: DexCell.State = .init(style: .destination),
            quote: Result<DexQuoteOutput, UX.Error>? = nil,
            defaultFiatCurrency: FiatCurrency? = nil,
            allowance: Allowance = .init(),
            confirmation: DexConfirmation.State? = nil
        ) {
            self.availableBalances = availableBalances
            self.source = source
            self.destination = destination
            self.quote = quote
            self.defaultFiatCurrency = defaultFiatCurrency
            self.allowance = allowance
        }

        var isLowBalance: Bool {
            guard
                let balance = source.balance?.value,
                let amount = source.amount
            else {
                return false
            }

            return (try? amount > balance) ?? false
        }
    }
}

extension DexMain.State {
    struct Allowance: Equatable {
        enum Status: Equatable {
            case unknown
            case notRequired
            case required
            case pending
            case complete

            var finished: Bool {
                switch self {
                case .notRequired, .complete:
                    return true
                case .pending, .required, .unknown:
                    return false
                }
            }
        }

        var result: DexAllowanceResult?
        @BindingState var transactionHash: String?

        var status: Status {
            switch (transactionHash != nil, result) {
            case (false, nil):
                return .unknown
            case (false, .nok):
                return .required
            case (false, .ok):
                return .notRequired

            case (true, .nok), (true, nil):
                return .pending
            case (true, .ok):
                return .complete
            }
        }
    }
}

extension Equatable {

    func setup(_ body: (inout Self) -> Void) -> Self {
        var copy = self
        body(&copy)
        return copy
    }
}

enum ContinueButtonState: Hashable {
    case selectToken
    case enterAmount
    case previewSwapDisabled
    case previewSwap
    case noAssetOnNetwork(EVMNetwork)
    case error(UX.Error)

    var title: String {
        switch self {
        case .noAssetOnNetwork(let network):
            return L10n.Main.noAssetsOnNetwork.interpolating(network.networkConfig.shortName)
        case .selectToken:
            return L10n.Main.selectAToken
        case .enterAmount:
            return L10n.Main.enterAnAmount
        case .previewSwapDisabled, .previewSwap:
            return L10n.Main.previewSwap
        case .error(let error):
            return error.title
        }
    }
}

extension DexMain.State {

    var continueButtonState: ContinueButtonState {
        if let currentNetwork, availableBalances != nil, source.filteredBalances.isEmpty == true {
            return .noAssetOnNetwork(currentNetwork)
        }
        guard source.currency != nil else {
            return .selectToken
        }
        guard destination.currency != nil else {
            return .selectToken
        }
        guard source.amount?.isPositive == true else {
            return .enterAmount
        }
        guard quote != nil else {
            return .previewSwapDisabled
        }
        if let error = quote?.failure {
            return .error(error)
        }
        guard allowance.status.finished, quote?.success?.isValidated == true else {
            return .previewSwapDisabled
        }
        return .previewSwap
    }
}

func lowBalanceUxError(_ currency: CryptoCurrency) -> UX.Error {
    UX.Error(
        title: "Not enough \(currency.displayCode)",
        message: "You do not have enough \(currency.displayCode) to commit this transaction"
    )
}
