// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureTransactionDomain
import Foundation
import MoneyKit

public struct SwapEnterAmount: ReducerProtocol {
    var defaultSwapPairsService: DefaultSwapCurrencyPairsServiceAPI
    var app: AppProtocol

    public init(
        app: AppProtocol,
        defaultSwaptPairsService: DefaultSwapCurrencyPairsServiceAPI
    ) {
        self.defaultSwapPairsService = defaultSwaptPairsService
        self.app = app
    }

    public struct State: Equatable {
        var isEnteringFiat: Bool = true
        var source: CryptoCurrency?
        var target: CryptoCurrency?
        var moneyValue: FiatValue?

        var fullInputText: String = ""
        var selectedMoneyValue: MoneyValue?

        @BindingState var sourceBalance: MoneyValue?
        @BindingState var inputText: String = ""
        @BindingState var sourceValuePrice: MoneyValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?

        public init() {}

        var mainFieldText: String {
            if isEnteringFiat {
                return amountFiatEntered?.toDisplayString(includeSymbol: true, format: .shortened) ?? defaultZeroFiat
            } else {
                return amountCryptoEntered?.toDisplayString(includeSymbol: true) ?? defaultZeroCryptoCurrency
            }
        }

        var secondaryFieldText: String {
            if isEnteringFiat == true {
                return amountFiatEntered?
                    .moneyValue
                    .toCryptoAmount(
                        currency: source?.currencyType.cryptoCurrency,
                        cryptoPrice: sourceValuePrice
                    )
                ?? defaultZeroCryptoCurrency
            } else {
                return amountCryptoEntered?
                    .toFiatAmount(with: sourceValuePrice)?
                    .toDisplayString(includeSymbol: true, format: .shortened) ?? defaultZeroFiat
            }
        }

        private var defaultZeroFiat: String {
            defaultFiatCurrency.flatMap(FiatValue.zero(currency:))?.toDisplayString(includeSymbol: true, format: .shortened) ?? ""
        }

        private var defaultZeroCryptoCurrency: String {
            guard let source else {
                return ""
            }
            return CryptoValue(storeAmount: 0, currency: source).toDisplayString(includeSymbol: true)
        }

        var maxAmountToSwap: MoneyValue? {
            if isEnteringFiat {
                return sourceBalance?.cryptoValue?.toFiatAmount(with: sourceValuePrice)?.moneyValue
            } else {
                return sourceBalance
            }
        }

        private var amountFiatEntered: FiatValue? {
            guard let currency = defaultFiatCurrency else {
                return nil
            }

            guard fullInputText.isNotEmpty else {
                return nil
            }

            return FiatValue
                .create(
                    major: fullInputText,
                    currency: currency
                )
        }

        private var amountCryptoEntered: CryptoValue? {
            guard let currency = source?.currencyType.cryptoCurrency else {
                return nil
            }

            guard fullInputText.isNotEmpty else {
                return nil
            }

            return CryptoValue.create(
                minor: fullInputText,
                currency: currency
            )
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case didFetchPairs(source: CryptoCurrency, target: CryptoCurrency)
        case didFetchSourceBalance(MoneyValue?)
        case onPreviewTapped
        case onChangeInputTapped
        case onMaxButtonTapped
        case binding(BindingAction<SwapEnterAmount.State>)
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { run in
                    if let pairs = await defaultSwapPairsService.getDefaultPairs() {
                        await run.send(.didFetchPairs(source: pairs.source, target: pairs.target))
                        let appMode = await app.mode()
                        switch appMode {
                        case .pkw:
                            let balance = try? await app.get(blockchain.user.pkw.asset[pairs.0.code].balance, as: MoneyValue.self)
                            await run.send(.didFetchSourceBalance(balance))
                        case .trading, .universal:
                            let balance = try? await app.get(blockchain.user.trading.account[pairs.0.code].balance.available, as: MoneyValue.self)
                            await run.send(.didFetchSourceBalance(balance))
                        }
                    }
                }

            case .didFetchSourceBalance(let moneyValue):
                state.sourceBalance = moneyValue
                return .none

            case .didFetchPairs(let sourceCryptoCurrency, let targetCryptoCurrency):
                state.source = sourceCryptoCurrency
                state.target = targetCryptoCurrency
                return .none

            case .binding(\.$inputText):
                state.fullInputText.appendAndFormat(state.inputText)
                return .none
            case .onChangeInputTapped:
                state.isEnteringFiat.toggle()
                return .none
            case .onPreviewTapped:
                return .none
            case .onMaxButtonTapped:
                if let inputText = state.maxAmountToSwap?.shortDisplayString.digits {
                    state.fullInputText = inputText
                }
                return .none
            case .binding:
                return .none
            }
        }
    }
}

extension String {
    var digits: String {
        components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }

    mutating func appendAndFormat(_ other: String) {
        if other == "delete" {
            // Delete the last character
            if !isEmpty {
                removeLast()
            }

            // If the last remaining character is ".", delete it
            if last == "." {
                removeLast()
            }
        } else {
            let decimalIndex = firstIndex(of: ".")
            let shouldAppend = decimalIndex == nil || decimalIndex.map { self.distance(from: $0, to: self.endIndex) < 3 } ?? true

            if shouldAppend {
                append(other)
            }

            let regexPattern = "(\\.)(?=.*\\.)"
            let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
            let range = NSRange(location: 0, length: utf16.count)

            let formattedString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
            self = formattedString
        }
    }
}
