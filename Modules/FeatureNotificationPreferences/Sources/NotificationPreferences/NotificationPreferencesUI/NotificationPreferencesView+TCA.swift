// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import ComposableNavigation
import Errors
import FeatureNotificationPreferencesDetailsUI
import FeatureNotificationPreferencesDomain
import Foundation
import SwiftUI

// MARK: - State

public struct NotificationPreferencesState: Hashable, NavigationState {
    public enum ViewState: Equatable, Hashable {
        case loading
        case data(notificationDetailsState: [NotificationPreference])
        case error
    }

    public var route: RouteIntent<NotificationsSettingsRoute>?
    public var viewState: ViewState
    public var notificationDetailsState: NotificationPreferencesDetailsState?

    public var notificationPrefrences: [NotificationPreference]?

    public init(
        route: RouteIntent<NotificationsSettingsRoute>? = nil,
        notificationDetailsState: NotificationPreferencesDetailsState? = nil,
        viewState: ViewState
    ) {
        self.route = route
        self.notificationDetailsState = notificationDetailsState
        self.viewState = viewState
    }
}

// MARK: - Actions

public enum NotificationPreferencesAction: Equatable, NavigationAction {
    case onAppear
    case onDissapear
    case onReloadTap
    case onSaveFailed
    case onPreferenceSelected(NotificationPreference)
    case notificationDetailsChanged(NotificationPreferencesDetailsAction)
    case onFetchedSettings(Result<[NotificationPreference], NetworkError>)
    case route(RouteIntent<NotificationsSettingsRoute>?)
}

// MARK: - Routing

public enum NotificationsSettingsRoute: NavigationRoute {
    case showDetails

    public func destination(in store: Store<NotificationPreferencesState, NotificationPreferencesAction>) -> some View {
        switch self {

        case .showDetails:
            return IfLetStore(
                store.scope(
                    state: \.notificationDetailsState,
                    action: NotificationPreferencesAction.notificationDetailsChanged
                ),
                then: { store in
                    NotificationPreferencesDetailsView(store: store)
                }
            )
        }
    }
}

// MARK: - Main Reducer

public let featureNotificationPreferencesMainReducer = Reducer<
    NotificationPreferencesState,
    NotificationPreferencesAction,
    NotificationPreferencesEnvironment
>
.combine(
    notificationPreferencesDetailsReducer
        .optional()
        .pullback(
            state: \.notificationDetailsState,
            action: /NotificationPreferencesAction.notificationDetailsChanged,
            environment: { _ -> NotificationPreferencesDetailsEnvironment in
                NotificationPreferencesDetailsEnvironment()
            }
        ),
    notificationPreferencesReducer
)

// MARK: - First screen reducer

public let notificationPreferencesReducer = Reducer
    .combine(
        Reducer<
            NotificationPreferencesState,
            NotificationPreferencesAction,
            NotificationPreferencesEnvironment
        > { state, action, environment in

            switch action {
            case .onAppear:
                return environment
                    .notificationPreferencesRepository
                    .fetchPreferences()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(NotificationPreferencesAction.onFetchedSettings)

            case .route(let routeItent):
                state.route = routeItent
                return .none

            case .onReloadTap:
                return environment
                    .notificationPreferencesRepository
                    .fetchPreferences()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(NotificationPreferencesAction.onFetchedSettings)

            case .notificationDetailsChanged(let action):
                switch action {
                case .save:
                    guard let preferences = state.notificationDetailsState?.updatedPreferences else { return .none }
                    return environment
                        .notificationPreferencesRepository
                        .update(preferences: preferences)
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map { result in
                            if case .failure(let error) = result {
                                return NotificationPreferencesAction.onSaveFailed
                            }
                            return NotificationPreferencesAction.onReloadTap
                        }

                case .binding:
                    return .none
                case .onAppear:
                    return .none
                }

            case .onSaveFailed:
                return EffectTask(value: .onReloadTap)

            case .onPreferenceSelected(let preference):
                state.notificationDetailsState = NotificationPreferencesDetailsState(notificationPreference: preference)
                return .none

            case .onDissapear:
                return .none

            case .onFetchedSettings(let result):
                switch result {
                case .success(let preferences):
                    state.viewState = .data(notificationDetailsState: preferences)
                    return .none

                case .failure(let error):
                    state.viewState = .error
                    return .none
                }
            }
        }
    )
    .analytics()

// MARK: - Environment

public struct NotificationPreferencesEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let analyticsRecorder: AnalyticsEventRecorderAPI
    public let notificationPreferencesRepository: NotificationPreferencesRepositoryAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        notificationPreferencesRepository: NotificationPreferencesRepositoryAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
        self.notificationPreferencesRepository = notificationPreferencesRepository
    }
}

// MARK: - Analytics Extensions

extension NotificationPreferencesState {
    func analyticsEvent(for action: NotificationPreferencesAction) -> AnalyticsEvent? {
        switch action {
        case .onAppear:
            return AnalyticsEvents
                .New
                .NotificationPreferencesEvents
                .notificationViewed

        case .onPreferenceSelected(let preference):
            return AnalyticsEvents
                .New
                .NotificationPreferencesEvents
                .notificationPreferencesClicked(optionSelection: preference.type.analyticsValue)

        case .onDissapear:
            return AnalyticsEvents
                .New
                .NotificationPreferencesEvents
                .notificationsClosed

        case .onSaveFailed:
            guard let viewedPreference = notificationDetailsState?.notificationPreference else { return .none }
            return AnalyticsEvents
                .New
                .NotificationPreferencesEvents
                .statusChangeError(origin: viewedPreference.type.analyticsValue)

        case .notificationDetailsChanged(let action):
            switch action {
            case .save:
                return notificationDetailsState?.updatedAnalyticsEvent

            case .onAppear:
                guard let viewedPreference = notificationDetailsState?.notificationPreference else { return .none }
                return AnalyticsEvents
                    .New
                    .NotificationPreferencesEvents
                    .notificationPreferencesViewed(option_viewed: viewedPreference.type.analyticsValue)
            default:
                return nil
            }

        default:
            return nil
        }
    }
}

extension Reducer where
    Action == NotificationPreferencesAction,
    State == NotificationPreferencesState,
    Environment == NotificationPreferencesEnvironment
{
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                NotificationPreferencesState,
                NotificationPreferencesAction,
                NotificationPreferencesEnvironment
            > { state, action, env in
                guard let event = state.analyticsEvent(for: action) else {
                    return .none
                }
                return .fireAndForget {
                    env.analyticsRecorder.record(event: event)
                }
            }
        )
    }
}
