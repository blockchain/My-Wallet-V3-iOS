// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Describes a pin screen use-case within the bigger flow
enum PinScreenUseCase {

    /// Selection of a new PIN use case
    case select(previousPin: Pin?)

    /// Creation of a new PIN use case (comes after `select(previousPin:_)`)
    case create(firstPin: Pin)

    /// Verification of PIN on login
    case authenticateOnLogin

    /// Authenticate before enabling biometrics
    case authenticateBeforeEnablingBiometrics

    /// Verification of PIN before changing
    case authenticateBeforeChanging

    /// The associated pin value, if there is any
    var pin: Pin? {
        switch self {
        case .create(firstPin: let pin):
            pin
        case .select(previousPin: let pin) where pin != nil:
            pin
        default:
            nil
        }
    }

    /// Is authentication before enabling touch/face id
    var isAuthenticateBeforeEnablingBiometrics: Bool {
        switch self {
        case .authenticateBeforeEnablingBiometrics:
            true
        default:
            false
        }
    }

    /// Is authentication on login flow
    var isAuthenticateOnLogin: Bool {
        switch self {
        case .authenticateOnLogin:
            true
        default:
            false
        }
    }

    /// Is any form of authentication
    var isAuthenticate: Bool {
        switch self {
        case .authenticateOnLogin, .authenticateBeforeChanging, .authenticateBeforeEnablingBiometrics:
            true
        case .create, .select:
            false
        }
    }
}
