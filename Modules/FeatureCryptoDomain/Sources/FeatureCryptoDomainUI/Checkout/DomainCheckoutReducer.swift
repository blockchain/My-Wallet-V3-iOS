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
    func destination(in store: Store<DomainCheckoutState, DomainCheckoutAction>) -> some View {
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

struct DomainCheckoutEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let orderDomainRepository: OrderDomainRepositoryAPI
    let userInfoProvider: () -> AnyPublisher<OrderDomainUserInfo, Error>
}

let domainCheckoutReducer = Reducer<
    DomainCheckoutState,
    DomainCheckoutAction,
    DomainCheckoutEnvironment
> { state, action, environment in
    switch action {
    case .route:
        return .none
    case .binding(\DomainCheckoutState.$removeCandidate):
        return EffectTask(value: DomainCheckoutAction.set((\DomainCheckoutState.$isRemoveBottomSheetShown), true))
    case .binding(\DomainCheckoutState.$isRemoveBottomSheetShown):
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
        return EffectTask(value: DomainCheckoutAction.set((\DomainCheckoutState.$isRemoveBottomSheetShown), false))
    case .claimDomain:
        guard let domain = state.selectedDomains.first else {
            return .none
        }
        state.isLoading = true
        return environment
            .userInfoProvider()
            .ignoreFailure(setFailureType: OrderDomainRepositoryError.self)
            .flatMap { userInfo -> AnyPublisher<OrderDomainResult, OrderDomainRepositoryError> in
                environment
                    .orderDomainRepository
                    .createDomainOrder(
                        isFree: true,
                        domainName: domain.domainName.replacingOccurrences(of: ".blockchain", with: ""),
                        resolutionRecords: userInfo.resolutionRecords
                    )
            }
            .receive(on: environment.mainQueue)
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
        case .failure(let error):
            return .navigate(to: .confirmation(.error))
        }

    case .returnToBrowseDomains:
        return .none

    case .dismissFlow:
        return .none
    }
}
.binding()
.routing()
.analytics()

// MARK: - Private

extension Reducer where
    Action == DomainCheckoutAction,
    State == DomainCheckoutState,
    Environment == DomainCheckoutEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                DomainCheckoutState,
                DomainCheckoutAction,
                DomainCheckoutEnvironment
            > { state, action, environment in
                switch action {
                case .binding((\DomainCheckoutState.$termsSwitchIsOn)):
                    if state.termsSwitchIsOn {
                        environment.analyticsRecorder.record(event: .domainTermsAgreed)
                    }
                    return .none
                case .removeDomain:
                    environment.analyticsRecorder.record(event: .domainCartEmptied)
                    return .none
                case .claimDomain:
                    environment.analyticsRecorder.record(event: .registerDomainStarted)
                    return .none
                case .didClaimDomain(.success):
                    environment.analyticsRecorder.record(event: .registerDomainSucceeded)
                    return .none
                case .didClaimDomain(.failure):
                    environment.analyticsRecorder.record(event: .registerDomainFailed)
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
