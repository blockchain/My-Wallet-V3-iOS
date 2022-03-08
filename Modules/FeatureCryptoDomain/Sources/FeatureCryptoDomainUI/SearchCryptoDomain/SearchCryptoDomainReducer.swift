// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import OrderedCollections
import SwiftUI
import ToolKit

// MARK: - Type

enum SearchCryptoDomainRoute: NavigationRoute {

    case checkout

    @ViewBuilder
    func destination(in store: Store<SearchCryptoDomainState, SearchCryptoDomainAction>) -> some View {
        switch self {
        case .checkout:
            IfLetStore(
                store.scope(
                    state: \.checkoutState,
                    action: SearchCryptoDomainAction.checkoutAction
                ),
                then: DomainCheckoutView.init(store:)
            )
        }
    }
}

enum SearchCryptoDomainId {
    struct SearchDebounceId: Hashable {}
}

enum SearchCryptoDomainAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<SearchCryptoDomainRoute>?)
    case binding(BindingAction<SearchCryptoDomainState>)
    case onAppear
    case searchDomains
    case didReceiveDomainsResult(Result<[SearchDomainResult], SearchDomainRepositoryError>)
    case selectFreeDomain(SearchDomainResult)
    case selectPremiumDomain(SearchDomainResult)
    case didSelectPremiumDomain(Result<OrderDomainResult, OrderDomainRepositoryError>)
    case openPremiumDomainLink(URL)
    case checkoutAction(DomainCheckoutAction)
}

// MARK: - Properties

struct SearchCryptoDomainState: Equatable, NavigationState {

    @BindableState var searchText: String
    @BindableState var isSearchFieldSelected: Bool
    @BindableState var isSearchTextValid: Bool
    @BindableState var isAlertCardShown: Bool
    @BindableState var isPremiumDomainBottomSheetShown: Bool
    @BindableState var selectedPremiumDomain: SearchDomainResult?
    @BindableState var selectedPremiumDomainRedirectUrl: String?
    var isSearchResultsLoading: Bool
    var searchResults: [SearchDomainResult]
    var selectedDomains: OrderedSet<SearchDomainResult>
    var route: RouteIntent<SearchCryptoDomainRoute>?
    var checkoutState: DomainCheckoutState?

    init(
        searchText: String = "",
        isSearchFieldSelected: Bool = false,
        isSearchTextValid: Bool = true,
        isAlertCardShown: Bool = true,
        isPremiumDomainBottomSheetShown: Bool = false,
        selectedPremiumDomain: SearchDomainResult? = nil,
        isSearchResultsLoading: Bool = false,
        searchResults: [SearchDomainResult] = [],
        route: RouteIntent<SearchCryptoDomainRoute>? = nil,
        checkoutState: DomainCheckoutState? = nil
    ) {
        self.searchText = searchText
        self.isSearchFieldSelected = isSearchFieldSelected
        self.isSearchTextValid = isSearchTextValid
        self.isAlertCardShown = isAlertCardShown
        self.isPremiumDomainBottomSheetShown = isPremiumDomainBottomSheetShown
        self.selectedPremiumDomain = selectedPremiumDomain
        self.isSearchResultsLoading = isSearchResultsLoading
        self.searchResults = searchResults
        selectedDomains = OrderedSet([])
        self.route = route
        self.checkoutState = checkoutState
    }
}

struct SearchCryptoDomainEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let searchDomainRepository: SearchDomainRepositoryAPI
    let orderDomainRepository: OrderDomainRepositoryAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        searchDomainRepository: SearchDomainRepositoryAPI,
        orderDomainRepository: OrderDomainRepositoryAPI
    ) {
        self.mainQueue = mainQueue
        self.searchDomainRepository = searchDomainRepository
        self.orderDomainRepository = orderDomainRepository
    }
}

let searchCryptoDomainReducer = Reducer.combine(
    domainCheckoutReducer
        .optional()
        .pullback(
            state: \.checkoutState,
            action: /SearchCryptoDomainAction.checkoutAction,
            environment: {
                DomainCheckoutEnvironment(
                    mainQueue: $0.mainQueue,
                    orderDomainRepository: $0.orderDomainRepository
                )
            }
        ),
    Reducer<
        SearchCryptoDomainState,
        SearchCryptoDomainAction,
        SearchCryptoDomainEnvironment
    > { state, action, environment in
        switch action {
        case .binding(\.$searchText):
            state.isSearchTextValid = state.searchText.range(
                of: TextRegex.noSpecialCharacters.rawValue, options: .regularExpression
            ) != nil || state.searchText.isEmpty
            return state.isSearchTextValid ? Effect(value: .searchDomains) : .none

        case .binding(.set(\.$isPremiumDomainBottomSheetShown, false)):
            state.selectedPremiumDomain = nil
            return .none

        case .binding:
            return .none

        case .onAppear:
            return .none

        case .searchDomains:
            state.isSearchResultsLoading = true
            return environment
                .searchDomainRepository
                .searchResults(searchKey: state.searchText)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .debounce(
                    id: SearchCryptoDomainId.SearchDebounceId(),
                    for: .milliseconds(500),
                    scheduler: environment.mainQueue
                )
                .map { result in
                    .didReceiveDomainsResult(result)
                }

        case .didReceiveDomainsResult(let result):
            state.isSearchResultsLoading = false
            switch result {
            case .success(let searchedDomains):
                state.searchResults = searchedDomains
            case .failure(let error):
                print(error)
            }
            return .none

        case .selectFreeDomain(let domain):
            guard domain.domainType == .free,
                  domain.domainAvailability == .availableForFree
            else {
                return .none
            }
            state.selectedDomains.removeAll()
            state.selectedDomains.append(domain)
            return Effect(value: .navigate(to: .checkout))

        case .selectPremiumDomain(let domain):
            guard domain.domainType == .premium else {
                return .none
            }
            state.selectedPremiumDomain = domain
            return .merge(
                Effect(value: .set(\.$isPremiumDomainBottomSheetShown, true)),
                environment
                    .orderDomainRepository
                    .createDomainOrder(
                        isFree: false,
                        domainName: domain.domainName.replacingOccurrences(of: ".blockchain", with: ""),
                        walletAddress: "",
                        nabuUserId: ""
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result in
                        switch result {
                        case .success(let orderResult):
                            return .didSelectPremiumDomain(.success(orderResult))
                        case .failure(let error):
                            return .didSelectPremiumDomain(.failure(error))
                        }
                    }
            )

        case .didSelectPremiumDomain(let result):
            switch result {
            case .success(let orderResult):
                state.selectedPremiumDomainRedirectUrl = orderResult.redirectUrl
                return .none
            case .failure(let error):
                print(error.localizedDescription)
                return .none
            }

        case .openPremiumDomainLink(let url):
            // TODO: remove this and use ExternalAppOpener when integrated with main target
            UIApplication.shared.open(url)
            return .none

        case .route(let route):
            if let routeValue = route?.route {
                switch routeValue {
                case .checkout:
                    state.checkoutState = .init(
                        selectedDomains: state.selectedDomains
                    )
                }
            }
            return .none

        case .checkoutAction(.removeDomain(let domain)):
            guard let domain = domain else {
                return .none
            }
            state.selectedDomains.remove(domain)
            return .none

        case .checkoutAction(.returnToBrowseDomains):
            return .dismiss()

        case .checkoutAction:
            return .none
        }
    }
    .routing()
    .binding()
)
