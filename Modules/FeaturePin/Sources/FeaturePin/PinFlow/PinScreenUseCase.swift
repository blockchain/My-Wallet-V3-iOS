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
            return pin
        case .select(previousPin: let pin) where pin != nil:
            return pin
        default:
            return nil
        }
    }

    /// Is authentication before enabling touch/face id
    var isAuthenticateBeforeEnablingBiometrics: Bool {
        switch self {
        case .authenticateBeforeEnablingBiometrics:
            return true
        default:
            return false
        }
    }

    /// Is authentication on login flow
    var isAuthenticateOnLogin: Bool {
        switch self {
        case .authenticateOnLogin:
            return true
        default:
            return false
        }
    }

    /// Is any form of authentication
    var isAuthenticate: Bool {
        switch self {
        case .authenticateOnLogin, .authenticateBeforeChanging, .authenticateBeforeEnablingBiometrics:
            return true
        case .create, .select:
            return false
        }
    }
}
