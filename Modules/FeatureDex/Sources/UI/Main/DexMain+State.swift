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

        var availableNetworks: [EVMNetwork] = []
        var currentNetwork: EVMNetwork? {
            didSet {
                currentSelectedNetworkTicker = currentNetwork?.networkConfig.networkTicker
                source.currentNetwork = currentNetwork
                destination.currentNetwork = currentNetwork
            }
        }

        var source: DexCell.State
        var destination: DexCell.State

        var quoteFetching: Bool = false
        var quote: Result<DexQuoteOutput, UX.Error>? {
            didSet {
                destination.overrideAmount = quote?.success?.buyAmount.amount
            }
        }

        var allowance: Allowance
        var confirmation: DexConfirmation.State?

        var networkNativePrice: FiatValue?
        @BindingState var slippage: Double = defaultSlippage
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var isConfirmationShown: Bool = false
        @BindingState var isEligible: Bool = true
        @BindingState var inegibilityReason: String?
        @BindingState var currentSelectedNetworkTicker: String? = nil

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
            guard
                let networkFee = quote?.success?.networkFee,
                networkFee.currency == amount.currency
            else {
                return (try? amount >= balance) ?? false
            }
            do {
                let sum = try amount + networkFee
                return try sum >= balance
            } catch {
                return false
            }
        }

        var isLowBalanceForGas: Bool {
            guard let output = quote?.success else {
                return false
            }
            let sellCurrency = output.sellAmount.currency
            let feeCurrency = output.networkFee.currency
            guard let feeCurrencyBalance = availableBalances?.first(where: { $0.currency == feeCurrency }) else {
                return false
            }
            var base = output.networkFee
            if sellCurrency == feeCurrency, let result = try? output.networkFee + output.sellAmount {
                base = result
            }
            return (try? base > feeCurrencyBalance.value) ?? false
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
                return .error(DexUXError.insufficientFundsForGas(output.networkFee.currency))
            }
            return .previewSwap
        }
    }

    var extraButtonState: ExtraButtonState? {
        guard
            let source = source.currency,
            case let .error(error) = continueButtonState
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

    static func insufficientFundsForGas(_ currency: CryptoCurrency) -> UX.Error {
        UX.Error(
            id: DexQuoteErrorId.insufficientFundsForGas,
            title: L10n.Main.NoBalanceError.titleGas.interpolating(currency.displayCode),
            message: L10n.Main.NoBalanceError.message.interpolating(currency.displayCode)
        )
    }
}

enum DexQuoteErrorId {
    static let insufficientFundsForGas = "dex.quote.insufficient.funds.for.gas"
    static let insufficientFunds = "dex.quote.insufficient.funds"
}

