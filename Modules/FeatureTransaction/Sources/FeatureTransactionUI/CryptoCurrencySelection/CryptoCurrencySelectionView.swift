// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import FeatureTransactionDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit
import UIComponentsKit

private typealias LocalizedStrings = LocalizationConstants.CryptoCurrencySelection

public struct CryptoCurrencySelectionState: Equatable {
    public init(
        fetchedCryptoCurrencies: IdentifiedArrayOf<CryptoCurrencyQuote> = [],
        loadingCryptoCurrencies: Bool = false,
        showDismissButton: Bool = true,
        showHeader: Bool = true,
        loadingErrorAlert: AlertState<CryptoCurrencySelectionAction>? = nil
    ) {
        self.fetchedCryptoCurrencies = fetchedCryptoCurrencies
        self.loadingCryptoCurrencies = loadingCryptoCurrencies
        self.showDismissButton = showDismissButton
        self.showHeader = showHeader
        self.loadingErrorAlert = loadingErrorAlert
    }

    var cryptoCurrencies: IdentifiedArrayOf<CryptoCurrencyQuote> {
        if searchQuery.isEmpty {
            return fetchedCryptoCurrencies
        } else {
            return filteredCryptoCurrencies
        }
    }

    var fetchedCryptoCurrencies: IdentifiedArrayOf<CryptoCurrencyQuote> = []
    var filteredCryptoCurrencies: IdentifiedArrayOf<CryptoCurrencyQuote> = []
    var searchQuery: String = ""

    var loadingCryptoCurrencies: Bool = false
    var showDismissButton: Bool = true
    var showHeader: Bool = true
    var loadingErrorAlert: AlertState<CryptoCurrencySelectionAction>?
}

public enum CryptoCurrencySelectionAction: Equatable {
    case didReceiveCryptoLoadingResponse(Result<[CryptoCurrencyQuote], CryptoCurrenciesServiceError>)
    case dismissLoadingAlert
    case loadCryptoCurrencies
    case closeButtonTapped
    case cellTapped(CryptoCurrencyQuote.ID, CryptoCurrencyQuoteAction)
    case skipButtonTapped
    case searchQueryChanged(String)
}

public struct CryptoCurrencySelectionEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        close: @escaping () -> Void,
        select: @escaping (CryptoCurrency) -> Void,
        loadCryptoCurrencies: @escaping () -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError>
    ) {
        self.mainQueue = mainQueue
        self.close = close
        self.select = select
        self.loadCryptoCurrencies = loadCryptoCurrencies
    }

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let close: () -> Void
    let select: (CryptoCurrency) -> Void
    let loadCryptoCurrencies: () -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError>
    let fuzzyAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    let fuzzyTolerance = 0.3
}

public typealias CryptoCurrencySelectionReducer = Reducer<
    CryptoCurrencySelectionState,
    CryptoCurrencySelectionAction,
    CryptoCurrencySelectionEnvironment
>

public let cryptoCurrencySelectionReducer = CryptoCurrencySelectionReducer { state, action, environment in
    switch action {
    case .didReceiveCryptoLoadingResponse(let result):
        state.loadingCryptoCurrencies = false
        switch result {
        case .success(let cryptoCurrencies):
            state.fetchedCryptoCurrencies = .init(uniqueElements: cryptoCurrencies)
        case .failure(let error):
            state.loadingErrorAlert = AlertState(
                title: TextState(LocalizedStrings.errorTitle),
                message: TextState(
                    String.localizedStringWithFormat(
                        LocalizedStrings.errorDescription,
                        String(describing: error)
                    )
                ),
                primaryButton: .default(
                    TextState(LocalizedStrings.errorButtonTitle),
                    action: .send(.loadCryptoCurrencies)
                ),
                secondaryButton: .cancel(TextState(LocalizedStrings.cancelButtonTitle))
            )
        }
        return .none

    case .dismissLoadingAlert:
        state.loadingErrorAlert = nil
        return .none

    case .loadCryptoCurrencies:
        state.loadingCryptoCurrencies = true
        return environment.loadCryptoCurrencies()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                .didReceiveCryptoLoadingResponse(result)
            }

    case .cellTapped(_, let subAction):
        switch subAction {
        case .select(let quote):
            environment.select(quote.cryptoCurrency)
        }
        return .none

    case .closeButtonTapped:
        environment.close()
        return .none

    case .skipButtonTapped:
        environment.close()
        return .none
    case .searchQueryChanged(let searchQuery):
        state.searchQuery = searchQuery
        state.filteredCryptoCurrencies = state.fetchedCryptoCurrencies.filter {
            let fuzzy = environment.fuzzyAlgorithm
            let tolerance = environment.fuzzyTolerance
            return fuzzy.distance(between: $0.cryptoCurrency.name, and: searchQuery) < tolerance ||
                fuzzy.distance(between: $0.cryptoCurrency.code, and: searchQuery) < tolerance
        }
        return .none
    }
}

public struct CryptoCurrencySelectionView: View {

    public init(store: Store<CryptoCurrencySelectionState, CryptoCurrencySelectionAction>) {
        self.store = store
    }

    let store: Store<CryptoCurrencySelectionState, CryptoCurrencySelectionAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                if viewStore.showHeader {
                    VStack(alignment: .leading, spacing: .zero) {
                        Text(LocalizedStrings.title)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                        Text(LocalizedStrings.description)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.text)
                    }
                    .padding()
                }

                if !viewStore.fetchedCryptoCurrencies.isEmpty {
                    HStack {
                        TextField(
                            LocalizedStrings.searchPlaceholder,
                            text: viewStore.binding(
                                get: \.searchQuery,
                                send: CryptoCurrencySelectionAction.searchQueryChanged
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocapitalization()
                        .disableAutocorrection(true)
                    }
                    .padding([.top, .leading, .trailing])
                }

                if viewStore.fetchedCryptoCurrencies.isEmpty, viewStore.loadingCryptoCurrencies {
                    Spacer()
                    ActivityIndicatorView()
                    Spacer()
                } else if viewStore.cryptoCurrencies.isEmpty {
                    Spacer()
                    VStack {
                        Text(LocalizedStrings.emptyListTitle)
                            .typography(.body1)
                            .foregroundColor(.semantic.body)

                        if viewStore.searchQuery.isEmpty {
                            PrimaryButton(title: LocalizedStrings.retryButtonTitle) {
                                viewStore.send(.loadCryptoCurrencies)
                            }
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    if viewStore.showHeader {
                        Divider()
                    }
                    List {
                        ForEachStore(
                            store.scope(
                                state: \.cryptoCurrencies,
                                action: CryptoCurrencySelectionAction.cellTapped
                            )
                        ) { cellStore in
                            CryptoCurrencyQuoteCell(store: cellStore)
                                .listRowSeparatorTint(Color.semantic.light)
                        }
                    }
                    .hideScrollContentBackground()
                }

                if viewStore.showDismissButton {
                    MinimalButton(title: LocalizedStrings.notNowButtonTitle) {
                        viewStore.send(.skipButtonTapped)
                    }
                    .padding()
                }
            }
            .onAppear {
                viewStore.send(.loadCryptoCurrencies)
            }
            .trailingNavigationButton(.close) {
                viewStore.send(.closeButtonTapped)
            }
            .alert(store.scope(state: \.loadingErrorAlert), dismiss: .dismissLoadingAlert)
        }
    }
}

extension View {
    func disableAutocapitalization() -> some View {
        textInputAutocapitalization(.never)
    }
}

#if DEBUG
struct SDDIntroBuyView_Previews: PreviewProvider {

    static var testCurrencyPairs = [
        CryptoCurrencyQuote(
            cryptoCurrency: .bitcoin,
            fiatCurrency: .USD,
            quote: 5000000,
            formattedQuote: "$50,000",
            priceChange: 10.0,
            formattedPriceChange: "+10.00%",
            timestamp: Date()
        ),
        CryptoCurrencyQuote(
            cryptoCurrency: .ethereum,
            fiatCurrency: .USD,
            quote: 150000,
            formattedQuote: "$1,500",
            priceChange: -5.0,
            formattedPriceChange: "-5.00%",
            timestamp: Date()
        ),
        CryptoCurrencyQuote(
            cryptoCurrency: .bitcoinCash,
            fiatCurrency: .USD,
            quote: 100,
            formattedQuote: "$1,00",
            priceChange: 0.0,
            formattedPriceChange: "0.00%",
            timestamp: Date()
        )
    ]

    static var previews: some View {
        Group {
            CryptoCurrencySelectionView(
                store: .init(
                    initialState: CryptoCurrencySelectionState(
                        loadingCryptoCurrencies: true
                    ),
                    reducer: cryptoCurrencySelectionReducer,
                    environment: CryptoCurrencySelectionEnvironment(
                        mainQueue: .main,
                        close: {},
                        select: { _ in },
                        loadCryptoCurrencies: { .just([]) }
                    )
                )
            )
            CryptoCurrencySelectionView(
                store: .init(
                    initialState: CryptoCurrencySelectionState(
                        fetchedCryptoCurrencies: .init(uniqueElements: testCurrencyPairs)
                    ),
                    reducer: cryptoCurrencySelectionReducer,
                    environment: CryptoCurrencySelectionEnvironment(
                        mainQueue: .main,
                        close: {},
                        select: { _ in },
                        loadCryptoCurrencies: { .just(testCurrencyPairs) }
                    )
                )
            )
        }
    }
}
#endif
