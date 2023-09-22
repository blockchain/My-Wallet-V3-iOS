// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import Foundation
import OrderedCollections
import SwiftUI
import ToolKit

enum DomainCheckoutRoute: NavigationRoute {
    case confirmation(DomainCheckoutConfirmationStatus)

    @ViewBuilder
    func destination(in store: Store<DomainCheckout.State, DomainCheckout.Action>) -> some View {
        let viewStore = ViewStore(store)
        switch self {
        case .confirmation(let status):
            if let selectedDomain = viewStore.selectedDomains.first {
                DomainCheckoutConfirmationView(
                    status: status,
                    domain: selectedDomain,
                    completion: { viewStore.send(.dismissFlow) }
                )
            }
        }
    }
}

enum DomainCheckoutAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<DomainCheckoutRoute>?)
    case binding(BindingAction<DomainCheckoutState>)
    case removeDomain(SearchDomainResult?)
    case claimDomain
    case didClaimDomain(Result<EmptyValue, OrderDomainRepositoryError>)
    case returnToBrowseDomains
    case dismissFlow
}

struct DomainCheckoutState: Equatable, NavigationState {
    @BindingState var termsSwitchIsOn = false
    @BindingState var isRemoveBottomSheetShown = false
    @BindingState var removeCandidate: SearchDomainResult?
    var isLoading: Bool = false
    var selectedDomains: OrderedSet<SearchDomainResult>
    var route: RouteIntent<DomainCheckoutRoute>?

    init(
        selectedDomains: OrderedSet<SearchDomainResult> = OrderedSet([])
    ) {
        self.selectedDomains = selectedDomains
    }
}

struct DomainCheckout: ReducerProtocol {
    typealias State = DomainCheckoutState
    typealias Action = DomainCheckoutAction

    @Dependency(\.mainQueue) var mainQueue
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let orderDomainRepository: OrderDomainRepositoryAPI
    let userInfoProvider: () -> AnyPublisher<OrderDomainUserInfo, Error>

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .route:
                return .none
            case .binding(\State.$removeCandidate):
                return EffectTask(value: Action.set((\State.$isRemoveBottomSheetShown), true))
            case .binding(\State.$isRemoveBottomSheetShown):
                if state.isRemoveBottomSheetShown {
                    state.removeCandidate = nil
                }
                return .none
            case .binding:
                return .none
            case .removeDomain(let domain):
                guard let domain else {
                    return .none
                }
                state.selectedDomains.remove(domain)
                return EffectTask(value: Action.set((\State.$isRemoveBottomSheetShown), false))
            case .claimDomain:
                guard let domain = state.selectedDomains.first else {
                    return .none
                }
                state.isLoading = true
                return userInfoProvider()
                    .ignoreFailure(setFailureType: OrderDomainRepositoryError.self)
                    .flatMap { [orderDomainRepository] userInfo -> AnyPublisher<OrderDomainResult, OrderDomainRepositoryError> in
                        orderDomainRepository
                            .createDomainOrder(
                                isFree: true,
                                domainName: domain.domainName.replacingOccurrences(of: ".blockchain", with: ""),
                                resolutionRecords: userInfo.resolutionRecords
                            )
                    }
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .map { result in
                        switch result {
                        case .success:
                            return .didClaimDomain(.success(.noValue))
                        case .failure(let error):
                            return .didClaimDomain(.failure(error))
                        }
                    }

            case .didClaimDomain(let result):
                state.isLoading = false
                switch result {
                case .success:
                    return .navigate(to: .confirmation(.success))
                case .failure:
                    return .navigate(to: .confirmation(.error))
                }

            case .returnToBrowseDomains:
                return .none

            case .dismissFlow:
                return .none
            }
        }
        .routing()
        DomainCheckoutAnalytics(analyticsRecorder: analyticsRecorder)
    }
}

struct DomainCheckoutAnalytics: ReducerProtocol {

    typealias State = DomainCheckoutState
    typealias Action = DomainCheckoutAction

    let analyticsRecorder: AnalyticsEventRecorderAPI

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .binding((\DomainCheckoutState.$termsSwitchIsOn)):
            if state.termsSwitchIsOn {
                analyticsRecorder.record(event: .domainTermsAgreed)
            }
            return .none
        case .removeDomain:
            analyticsRecorder.record(event: .domainCartEmptied)
            return .none
        case .claimDomain:
            analyticsRecorder.record(event: .registerDomainStarted)
            return .none
        case .didClaimDomain(.success):
            analyticsRecorder.record(event: .registerDomainSucceeded)
            return .none
        case .didClaimDomain(.failure):
            analyticsRecorder.record(event: .registerDomainFailed)
            return .none
        default:
            return .none
        }
    }
}
