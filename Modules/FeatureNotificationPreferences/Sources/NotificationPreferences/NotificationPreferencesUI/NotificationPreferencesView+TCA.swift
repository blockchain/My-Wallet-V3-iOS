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

public struct FeatureNotificationPreferencesMainReducer: Reducer {

    public typealias State = NotificationPreferencesState
    public typealias Action = NotificationPreferencesAction

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

    public var body: some Reducer<State, Action> {
        NotificationPreferencesReducer(
            mainQueue: mainQueue,
            notificationPreferencesRepository: notificationPreferencesRepository,
            analyticsRecorder: analyticsRecorder
        )
        .ifLet(\.notificationDetailsState, action: /Action.notificationDetailsChanged) {
            NotificationPreferencesDetailsReducer()
        }
    }
}

// MARK: - Environment

public struct NotificationPreferencesReducer: Reducer {

    public typealias State = NotificationPreferencesState
    public typealias Action = NotificationPreferencesAction

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

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .publisher {
                    notificationPreferencesRepository
                        .fetchPreferences()
                        .receive(on: mainQueue)
                        .map { .onFetchedSettings(.success($0)) }
                        .catch { .onFetchedSettings(.failure($0)) }
                }

            case .route(let routeItent):
                state.route = routeItent
                return .none

            case .onReloadTap:
                return .publisher {
                    notificationPreferencesRepository
                        .fetchPreferences()
                        .receive(on: mainQueue)
                        .map { .onFetchedSettings(.success($0)) }
                        .catch { .onFetchedSettings(.failure($0)) }
                }

            case .notificationDetailsChanged(let action):
                switch action {
                case .save:
                    guard let preferences = state.notificationDetailsState?.updatedPreferences else { return .none }
                    return .run { send in
                        do {
                            try await notificationPreferencesRepository
                                .update(preferences: preferences)
                                .receive(on: mainQueue)
                                .await()
                            await send(.onReloadTap)
                        } catch {
                            await send(.onSaveFailed)
                        }
                    }

                case .binding:
                    return .none
                case .onAppear:
                    return .none
                }

            case .onSaveFailed:
                return Effect.send(.onReloadTap)

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

                case .failure:
                    state.viewState = .error
                    return .none
                }
            }
        }
        NotificationPreferencesAnalytics(analyticsRecorder: analyticsRecorder)
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

struct NotificationPreferencesAnalytics: Reducer {

    typealias Action = NotificationPreferencesAction
    typealias State = NotificationPreferencesState

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            guard let event = state.analyticsEvent(for: action) else {
                return .none
            }
            return .run { _ in
                analyticsRecorder.record(event: event)
            }
        }
    }
}
