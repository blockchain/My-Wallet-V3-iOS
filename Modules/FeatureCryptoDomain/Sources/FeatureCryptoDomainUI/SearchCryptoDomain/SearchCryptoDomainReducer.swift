// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
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
    case searchDomainsWithUsername
    case searchDomains(key: String, freeOnly: Bool = false)
    case didReceiveDomainsResult(Result<[SearchDomainResult], SearchDomainRepositoryError>, Bool)
    case selectFreeDomain(SearchDomainResult)
    case selectPremiumDomain(SearchDomainResult)
    case didSelectPremiumDomain(Result<OrderDomainResult, OrderDomainRepositoryError>)
    case openPremiumDomainLink(URL)
    case checkoutAction(DomainCheckoutAction)
    case noop
}

// MARK: - Properties

struct SearchCryptoDomainState: Equatable, NavigationState {

    @BindingState var searchText: String
    @BindingState var isSearchFieldSelected: Bool
    @BindingState var isSearchTextValid: Bool
    @BindingState var isAlertCardShown: Bool
    @BindingState var isPremiumDomainBottomSheetShown: Bool
    var selectedPremiumDomain: SearchDomainResult?
    var selectedPremiumDomainRedirectUrl: String?
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
        self.selectedDomains = OrderedSet([])
        self.route = route
        self.checkoutState = checkoutState
    }
}

struct SearchCryptoDomainEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let externalAppOpener: ExternalAppOpener
    let searchDomainRepository: SearchDomainRepositoryAPI
    let orderDomainRepository: OrderDomainRepositoryAPI
    let userInfoProvider: () -> AnyPublisher<OrderDomainUserInfo, Error>

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        externalAppOpener: ExternalAppOpener,
        searchDomainRepository: SearchDomainRepositoryAPI,
        orderDomainRepository: OrderDomainRepositoryAPI,
        userInfoProvider: @escaping () -> AnyPublisher<OrderDomainUserInfo, Error>
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
        self.externalAppOpener = externalAppOpener
        self.searchDomainRepository = searchDomainRepository
        self.orderDomainRepository = orderDomainRepository
        self.userInfoProvider = userInfoProvider
    }
}

let searchCryptoDomainReducer = Reducer<SearchCryptoDomainState, SearchCryptoDomainAction, SearchCryptoDomainEnvironment>.combine(
    domainCheckoutReducer
        .optional()
        .pullback(
            state: \SearchCryptoDomainState.checkoutState,
            action: /SearchCryptoDomainAction.checkoutAction,
            environment: {
                DomainCheckoutEnvironment(
                    mainQueue: $0.mainQueue,
                    analyticsRecorder: $0.analyticsRecorder,
                    orderDomainRepository: $0.orderDomainRepository,
                    userInfoProvider: $0.userInfoProvider
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
            return state.isSearchTextValid ? EffectTask(value: .searchDomains(key: state.searchText)) : .none

        case .binding(\.$isPremiumDomainBottomSheetShown):
            if !state.isPremiumDomainBottomSheetShown {
                state.selectedPremiumDomain = nil
                state.selectedPremiumDomainRedirectUrl = nil
            }
            return .none

        case .binding:
            return .none

        case .onAppear:
            return EffectTask(value: .searchDomainsWithUsername)

        case .searchDomainsWithUsername:
            guard state.searchText.isEmpty else {
                return .none
            }
            return environment
                .userInfoProvider()
                .compactMap(\.nabuUserName)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result in
                    if case .success(let username) = result {
                        return .searchDomains(key: username, freeOnly: true)
                    }
                    return .noop
                }

        case .searchDomains(let key, let isFreeOnly):
            if key.isEmpty {
                return EffectTask(value: .searchDomainsWithUsername)
            }
            state.isSearchResultsLoading = true
            return environment
                .searchDomainRepository
                .searchResults(searchKey: key, freeOnly: isFreeOnly)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .debounce(
                    id: SearchCryptoDomainId.SearchDebounceId(),
                    for: .milliseconds(500),
                    scheduler: environment.mainQueue
                )
                .map { result in
                    .didReceiveDomainsResult(result, isFreeOnly)
                }

        case .didReceiveDomainsResult(let result, _):
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
            return EffectTask(value: .navigate(to: .checkout))

        case .selectPremiumDomain(let domain):
            guard domain.domainType == .premium else {
                return .none
            }
            state.selectedPremiumDomain = domain
            return .merge(
                EffectTask(value: .set(\.$isPremiumDomainBottomSheetShown, true)),
                environment
                    .userInfoProvider()
                    .ignoreFailure(setFailureType: OrderDomainRepositoryError.self)
                    .flatMap { userInfo -> AnyPublisher<OrderDomainResult, OrderDomainRepositoryError> in
                        environment
                            .orderDomainRepository
                            .createDomainOrder(
                                isFree: false,
                                domainName: domain.domainName.replacingOccurrences(of: ".blockchain", with: ""),
                                resolutionRecords: userInfo.resolutionRecords
                            )
                    }
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
            environment
                .externalAppOpener
                .open(url)
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
            guard let domain else {
                return .none
            }
            state.selectedDomains.remove(domain)
            return .dismiss()

        case .checkoutAction(.returnToBrowseDomains):
            return .dismiss()

        case .checkoutAction:
            return .none

        case .noop:
            return .none
        }
    }
    .routing()
    .binding()
    .analytics()
)

// MARK: - Private

extension Reducer where
    Action == SearchCryptoDomainAction,
    State == SearchCryptoDomainState,
    Environment == SearchCryptoDomainEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                SearchCryptoDomainState,
                SearchCryptoDomainAction,
                SearchCryptoDomainEnvironment
            > { _, action, environment in
                switch action {
                case .didReceiveDomainsResult(.success, let isFreeOnly):
                    if !isFreeOnly {
                        environment.analyticsRecorder.record(event: .searchDomainManual)
                    }
                    environment.analyticsRecorder.record(event: .searchDomainLoaded)
                    return .none
                case .openPremiumDomainLink:
                    environment.analyticsRecorder.record(event: .unstoppableSiteVisited)
                    return .none
                case .selectFreeDomain:
                    environment.analyticsRecorder.record(event: .domainSelected)
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
