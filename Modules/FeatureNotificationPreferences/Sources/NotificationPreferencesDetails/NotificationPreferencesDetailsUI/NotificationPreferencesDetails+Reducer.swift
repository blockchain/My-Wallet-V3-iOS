// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureNotificationPreferencesDomain
import Foundation

public struct NotificationPreferencesDetailsReducer: ReducerProtocol {

    public typealias State = NotificationPreferencesDetailsState
    public typealias Action = NotificationPreferencesDetailsAction

    public init() {}

    public var body: some ReducerProtocol<State,Action> {
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
