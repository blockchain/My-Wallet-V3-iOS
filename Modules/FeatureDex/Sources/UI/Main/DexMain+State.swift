// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import ComposableArchitecture
import FeatureDexDomain
import MoneyKit

extension DexMain {

    public struct State: Equatable {
        
        var availableBalances: [DexBalance] {
            didSet {
                source.availableBalances = availableBalances
                destination.availableBalances = availableBalances
            }
        }

        var availableChains: [Chain] = [] {
            didSet {
                networkPickerState.availableChains = availableChains
//                currentNetwork = availableNetworks.first
            }
        }

        var currentChain: Chain? = nil {
            didSet {
                
            }
        }
        
//        var availableNetworks: [EVMNetwork] = [EVMNetwork.init(networkConfig: .ethereum, nativeAsset: .ethereum),
//                                               EVMNetwork.init(networkConfig: .bitcoin, nativeAsset: .bitcoin)] {
//            didSet {
//                networkPickerState.availableNetworks = availableNetworks
//                // TODO: @audrea when `availableNetworks` is set,
//                // default to (chainID 1/Eth) or if that doesnt exist, default to first of the list
//            }
//        }
        var currentNetwork: EVMNetwork? = nil {
            didSet {
                source.currentNetwork = currentNetwork
                destination.currentNetwork = currentNetwork
                // TODO: @audrea source.currentNetwork = currentNetwork
                // TODO: @audrea destination.currentNetwork = currentNetwork
            }
        }

        var source: DexCell.State
        var destination: DexCell.State
        var networkPickerState: NetworkPicker.State = NetworkPicker.State()

        var quote: Result<DexQuoteOutput, UX.Error>? {
            didSet {
                destination.overrideAmount = quote?.success?.buyAmount.amount
            }
        }

        var allowance: Allowance
        var confirmation: DexConfirmation.State?

        var error: UX.Error? {
            if let error = quote?.failure {
                return error
            }
            if isLowBalance, let currency = source.currency {
                return UX.Error(
                    title: "Not enough \(currency.displayCode)",
                    message: "You do not have enough \(currency.displayCode) to commit this transaction"
                )
            }
            return nil
        }

        @BindingState var slippage: Double = defaultSlippage
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var isConfirmationShown: Bool = false
        @BindingState var isSelectNetworkShown: Bool = false

        init(
            availableBalances: [DexBalance] = [],
            source: DexCell.State = .init(style: .source),
            destination: DexCell.State = .init(style: .destination),
            quote: Result<DexQuoteOutput, UX.Error>? = nil,
            defaultFiatCurrency: FiatCurrency? = nil,
            allowance: Allowance = .init()
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
    case error(UX.Error)

    var title: String {
        switch self {
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

    var isGettingFirstQuote: Bool {
        // TODO: @audrea
        quote == nil
            && allowance.result == nil
            && continueButtonState == .previewSwapDisabled
    }

    var continueButtonState: ContinueButtonState {
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
        if let error {
            return .error(error)
        }
        guard allowance.status.finished, quote?.success?.isValidated == true else {
            return .previewSwapDisabled
        }
        return .previewSwap
    }
}
