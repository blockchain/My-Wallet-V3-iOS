// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureNotificationPreferencesDomain
import Foundation

public struct NotificationPreferencesDetailsReducer: Reducer {

    public typealias State = NotificationPreferencesDetailsState
    public typealias Action = NotificationPreferencesDetailsAction

    public init() {}

    public var body: some Reducer<State,Action> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            case .save:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
