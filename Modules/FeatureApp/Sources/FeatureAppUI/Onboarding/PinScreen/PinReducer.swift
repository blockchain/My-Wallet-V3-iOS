// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit

public enum PinCore {
    public enum Action: Equatable {
        /// Displays the Pin screen for authentication
        case authenticate
        /// Displays the Pin screen for creating a pin
        case create
        /// Performs a logout
        case logout
        /// Action that gets called with the pin is created
        case pinCreated
        /// Sent by the pin screen to perform wallet authentication
        case handleAuthentication(_ password: String)
        case none
    }

    public struct State: Equatable {
        public var creating: Bool = false
        public var authenticate: Bool = false

        /// Determines if the state requires Pin
        var requiresPinAuthentication: Bool {
            authenticate
        }

        public init(
            creating: Bool = false,
            authenticate: Bool = false
        ) {
            self.creating = creating
            self.authenticate = authenticate
        }
    }

    public struct Environment {}
}

struct PinReducer: Reducer {

    typealias State = PinCore.State
    typealias Action = PinCore.Action

    let alertPresenter: AlertViewPresenterAPI

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .authenticate:
                state.creating = false
                state.authenticate = true
                return .none
            case .create:
                state.creating = true
                state.authenticate = false
                return .none
            case .logout:
                return .none
            case .handleAuthentication:
                return .none
            case .pinCreated:
                return .none
            case .none:
                return .none
            }
        }
    }
}
