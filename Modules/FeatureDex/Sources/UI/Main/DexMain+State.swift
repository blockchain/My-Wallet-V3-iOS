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

        var availableNetworks: [EVMNetwork] = []
        var source: DexCell.State
        var destination: DexCell.State

        var quoteFetching: Bool = false
        var quote: Result<DexQuoteOutput, UX.Error>? {
            didSet {
                switch quote {
                case .success(let output) where output.field == .source:
                    destination.overrideAmount = output.buyAmount.amount
                case .success(let output) where output.field == .destination:
                    source.overrideAmount = output.sellAmount
                default:
                    source.overrideAmount = nil
                    destination.overrideAmount = nil
                }
            }
        }

        var allowance: Allowance
        var confirmation: DexConfirmation.State?

        var settings: Settings
        @BindingState var isConfirmationShown: Bool = false
        @BindingState var isSettingsShown: Bool = false
        @BindingState var isEligible: Bool = true
        @BindingState var inegibilityReason: String?
        @BindingState var quoteByOutputEnabled: Bool = false
        @BindingState var crossChainEnabled: Bool = false

        init(
            availableBalances: [DexBalance]? = nil,
            source: DexCell.State = .init(style: .source),
            destination: DexCell.State = .init(style: .destination),
            quote: Result<DexQuoteOutput, UX.Error>? = nil,
            allowance: Allowance = .init(),
            confirmation: DexConfirmation.State? = nil,
            settings: Settings = .init()
        ) {
            self.availableBalances = availableBalances
            self.source = source
            self.destination = destination
            self.quote = quote
            self.allowance = allowance
            self.settings = settings
        }

        var isLowBalance: Bool {
            guard
                let balance = source.balance?.value,
                let amount = source.amount
            else {
                return false
            }
            guard
                let networkFee = quote?.success?.networkFee,
                networkFee.currency == amount.currency
            else {
                return (try? amount > balance) ?? false
            }
            do {
                let sum = try amount + networkFee
                return try sum > balance
            } catch {
                return false
            }
        }

        var isLowBalanceForGas: Bool {
            guard let output = quote?.success else {
                return false
            }
            guard let networkFee = output.networkFee else {
                return false
            }
            let sellCurrency = output.sellAmount.currency
            let feeCurrency = networkFee.currency
            guard let feeCurrencyBalance = availableBalances?.first(where: { $0.currency == feeCurrency }) else {
                return false
            }
            var base = networkFee
            if sellCurrency == feeCurrency, let result = try? networkFee + output.sellAmount {
                base = result
            }
            return (try? base > feeCurrencyBalance.value) ?? false
        }

        var status: Status {
            if isEligible.isNo {
                return .notEligible
            }
            if availableBalances.isNil || source.currentNetwork.isNil {
                return .loading
            }
            if availableBalances?.isEmpty == true {
                return .noBalance
            }
            return .ready
        }
    }
}

extension DexMain.State {
    enum Status {
        case loading
        case notEligible
        case noBalance
        case ready
    }
}

extension DexMain.State {
    struct Settings: Equatable {
        @BindingState var expressMode: Bool = true
        @BindingState var gasOnDestination: Bool = false
        @BindingState var slippage: Double = defaultSlippage
    }
}

extension DexMain.State {
    struct Allowance: Equatable {
        enum Status: Equatable {
            case unknown
            case notRequired
            case required(allowanceSpender: String)
            case pending
            case complete

            var allowanceSpender: String? {
                switch self {
                case .required(let value):
                    value
                default:
                    nil
                }
            }

            var finished: Bool {
                switch self {
                case .notRequired, .complete:
                    true
                case .pending, .required, .unknown:
                    false
                }
            }
        }

        var result: DexAllowanceResult?
        @BindingState var transactionHash: String?

        var status: Status {
            switch (transactionHash != nil, result) {
            case (false, nil):
                .unknown
            case (false, .nok(let allowanceSpender)):
                .required(allowanceSpender: allowanceSpender)
            case (false, .ok):
                .notRequired
            case (true, .nok), (true, nil):
                .pending
            case (true, .ok):
                .complete
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
            L10n.Main.noAssetsOnNetwork.interpolating(network.networkConfig.shortName)
        case .selectToken:
            L10n.Main.selectAToken
        case .enterAmount:
            L10n.Main.enterAnAmount
        case .previewSwapDisabled, .previewSwap:
            L10n.Main.previewSwap
        case .error(let error):
            error.title
        }
    }
}

extension DexMain.State {

    var continueButtonState: ContinueButtonState {
        if let currentNetwork = source.currentNetwork, availableBalances != nil, source.filteredBalances.isEmpty == true {
            return .noAssetOnNetwork(currentNetwork)
        }
        guard source.currency != nil else {
            return .selectToken
        }
        guard destination.currency != nil else {
            return .selectToken
        }
        guard source.inputAmountIsPositive || destination.inputAmountIsPositive else {
            return .enterAmount
        }
        switch quote {
        case nil:
            return .previewSwapDisabled
        case .failure(let error):
            return .error(error)
        case .success(let output):
            guard allowance.status.finished, output.isValidated else {
                return .previewSwapDisabled
            }
            if isLowBalanceForGas {
                return .error(DexUXError.insufficientFundsForGas(output.networkFee?.currency))
            }
            return .previewSwap
        }
    }

    var extraButtonState: ExtraButtonState? {
        guard
            let source = source.currency,
            case .error(let error) = continueButtonState
        else {
            return nil
        }
        switch error.id {
        case DexQuoteErrorId.insufficientFunds:
            return .deposit(source)
        case DexQuoteErrorId.insufficientFundsForGas:
            return source.network()
                .map(\.nativeAsset)
                .map(ExtraButtonState.deposit)
        default:
            return nil
        }
    }
}

enum ExtraButtonState: Hashable {
    case deposit(CryptoCurrency)
}

enum DexUXError {
    static func insufficientFunds(_ currency: CryptoCurrency) -> UX.Error {
        UX.Error(
            id: DexQuoteErrorId.insufficientFunds,
            title: L10n.Main.NoBalanceError.title.interpolating(currency.displayCode),
            message: L10n.Main.NoBalanceError.message.interpolating(currency.displayCode)
        )
    }

    static func insufficientFundsForGas(_ currency: CryptoCurrency?) -> UX.Error {
        let displayCode = currency?.displayCode ?? ""
        return UX.Error(
            id: DexQuoteErrorId.insufficientFundsForGas,
            title: L10n.Main.NoBalanceError.titleGas.interpolating(displayCode),
            message: L10n.Main.NoBalanceError.message.interpolating(displayCode)
        )
    }
}

enum DexQuoteErrorId {
    static let insufficientFundsForGas = "dex.quote.insufficient.funds.for.gas"
    static let insufficientFunds = "dex.quote.insufficient.funds"
}
