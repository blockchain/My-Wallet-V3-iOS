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

    @MainActor
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
    case checkoutAction(DomainCheckout.Action)
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
    var checkoutState: DomainCheckout.State?

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
        checkoutState: DomainCheckout.State? = nil
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

struct SearchCryptoDomain: Reducer {
    typealias State = SearchCryptoDomainState

    typealias Action = SearchCryptoDomainAction

    @Dependency(\.mainQueue) var mainQueue
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let externalAppOpener: ExternalAppOpener
    let searchDomainRepository: SearchDomainRepositoryAPI
    let orderDomainRepository: OrderDomainRepositoryAPI
    let userInfoProvider: () -> AnyPublisher<OrderDomainUserInfo, Error>

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$searchText):
                state.isSearchTextValid = state.searchText.range(
                    of: TextRegex.noSpecialCharacters.rawValue, options: .regularExpression
                ) != nil || state.searchText.isEmpty
                return state.isSearchTextValid ? Effect.send(.searchDomains(key: state.searchText)) : .none

            case .binding(\.$isPremiumDomainBottomSheetShown):
                if !state.isPremiumDomainBottomSheetShown {
                    state.selectedPremiumDomain = nil
                    state.selectedPremiumDomainRedirectUrl = nil
                }
                return .none

            case .binding:
                return .none

            case .onAppear:
                return Effect.send(.searchDomainsWithUsername)

            case .searchDomainsWithUsername:
                guard state.searchText.isEmpty else {
                    return .none
                }
                return .run { send in
                    do {
                        let username = try await userInfoProvider()
                            .compactMap(\.nabuUserName)
                            .receive(on: mainQueue)
                            .await()
                        await send(.searchDomains(key: username, freeOnly: true))
                    } catch {
                        await send(.noop)
                    }
                }

            case .searchDomains(let key, let isFreeOnly):
                if key.isEmpty {
                    return Effect.send(.searchDomainsWithUsername)
                }
                state.isSearchResultsLoading = true
                return .run { send in
                    do {
                        let results = try await searchDomainRepository
                            .searchResults(searchKey: key, freeOnly: isFreeOnly)
                            .receive(on: mainQueue)
                            .await()
                        await send(.didReceiveDomainsResult(.success(results), isFreeOnly))
                    } catch {
                        await send(.didReceiveDomainsResult(.failure(error as! SearchDomainRepositoryError), isFreeOnly))
                    }
                }
                .debounce(
                    id: SearchCryptoDomainId.SearchDebounceId(),
                    for: .milliseconds(500),
                    scheduler: mainQueue
                )

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
                return Effect.send(.navigate(to: .checkout))

            case .selectPremiumDomain(let domain):
                guard domain.domainType == .premium else {
                    return .none
                }
                state.selectedPremiumDomain = domain
                return .merge(
                    Effect.send(.set(\.$isPremiumDomainBottomSheetShown, true)),
                    .run { send in
                        do {
                            let orderResult = try await userInfoProvider()
                                .ignoreFailure(setFailureType: OrderDomainRepositoryError.self)
                                .flatMap { [orderDomainRepository] userInfo -> AnyPublisher<OrderDomainResult, OrderDomainRepositoryError> in
                                    orderDomainRepository
                                        .createDomainOrder(
                                            isFree: false,
                                            domainName: domain.domainName.replacingOccurrences(of: ".blockchain", with: ""),
                                            resolutionRecords: userInfo.resolutionRecords
                                        )
                                }
                                .receive(on: mainQueue).await()
                            await send(.didSelectPremiumDomain(.success(orderResult)))
                        } catch {
                            await send(.didSelectPremiumDomain(.failure(error as! OrderDomainRepositoryError)))
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
                externalAppOpener
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
        .ifLet(\.checkoutState, action: /Action.checkoutAction) {
            DomainCheckout(
                analyticsRecorder: analyticsRecorder,
                orderDomainRepository: orderDomainRepository,
                userInfoProvider: userInfoProvider
            )
        }
        .routing()
        SearchCryptoDomainAnalytics(analyticsRecorder: analyticsRecorder)
    }
}

// MARK: - Private

struct SearchCryptoDomainAnalytics: Reducer {

    typealias State = SearchCryptoDomainState
    typealias Action = SearchCryptoDomainAction

    let analyticsRecorder: AnalyticsEventRecorderAPI

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .didReceiveDomainsResult(.success, let isFreeOnly):
            if !isFreeOnly {
                analyticsRecorder.record(event: .searchDomainManual)
            }
            analyticsRecorder.record(event: .searchDomainLoaded)
            return .none
        case .openPremiumDomainLink:
            analyticsRecorder.record(event: .unstoppableSiteVisited)
            return .none
        case .selectFreeDomain:
            analyticsRecorder.record(event: .domainSelected)
            return .none
        default:
            return .none
        }
    }
}
