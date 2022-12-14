// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import ToolKit
import UIKit

public struct PinRouting {

    /// Any possible routing error along displaying / dismissing the PIN flow
    public enum FlowError: Error {
        /// Navigation controller is not initialized for some reason
        case navigationControllerIsNotInitialized

        /// Parent view controller must not be `nil` for foreground authentication
        case parentViewControllerNilOnForegroundAuthentication
    }

    /// The flow of the pin
    public enum Flow {

        /// The origin of the flow
        public enum Origin {

            /// In-app state that requires the user to re-authenticate to enable a feature
            case foreground(parent: UnretainedContentBox<UIViewController>)

            /// Background app state that requires the user's authentication to access the app
            case background

            case attachedOn(controller: UnretainedContentBox<UIViewController>)
        }

        /// Change old pin code to a new one
        case change(parent: UnretainedContentBox<UIViewController>, logoutRouting: RoutingType.Logout)

        /// Creation of a new pin code where none existed before
        case create(parent: UnretainedContentBox<UIViewController>)

        /// Creation of a new pin code where none existed before, allowing for a custom origin
        case createPin(from: Origin)

        /// Authentication flow: upon entering foreground
        case authenticate(from: Origin, logoutRouting: RoutingType.Logout)

        /// Enable biometrics
        case enableBiometrics(parent: UnretainedContentBox<UIViewController>, logoutRouting: RoutingType.Logout)

        /// Returns `true` if the flow is `create`
        public var isCreate: Bool {
            switch self {
            case .create:
                return true
            default:
                return false
            }
        }

        // Returns `true` for change pin flow
        public var isChange: Bool {
            switch self {
            case .change:
                return true
            default:
                return false
            }
        }

        /// Returns `true` for login authnetication
        public var isLoginAuthentication: Bool {
            switch self {
            case .authenticate(from: let origin, logoutRouting: _):
                switch origin {
                case .background:
                    return true
                case .attachedOn:
                    return false
                case .foreground:
                    return false
                }
            default:
                return false
            }
        }

        /// Returns the origin of the pin flow. The only possible background origin is for `.authneticate`.
        public var origin: Origin {
            switch self {
            case .authenticate(from: let origin, logoutRouting: _):
                return origin
            case .change(parent: let boxedParent, logoutRouting: _):
                return .foreground(parent: boxedParent)
            case .create(parent: let boxedParent):
                return .foreground(parent: boxedParent)
            case .createPin(from: let origin):
                return origin
            case .enableBiometrics(parent: let boxedParent, logoutRouting: _):
                return .foreground(parent: boxedParent)
            }
        }

        // Returns logout routing if configured for flow
        public var logoutRouting: RoutingType.Logout? {
            switch self {
            case .authenticate(from: _, logoutRouting: let routing):
                return routing
            case .change(parent: _, logoutRouting: let routing):
                return routing
            case .enableBiometrics(parent: _, logoutRouting: let routing):
                return routing
            case .create:
                return nil
            case .createPin:
                return nil
            }
        }

        /// Returns the parent of the login container. The only case that the login
        /// has no parent is authentication from background. In this case, the login container
        /// replaces the root view controller of the window.
        public var parent: UIViewController? {
            switch self {
            case .authenticate(from: let origin, logoutRouting: _):
                switch origin {
                case .foreground(parent: let parent):
                    return parent.value
                case .background: // Only case when there is no parent as the login is the root
                    return nil
                case .attachedOn(controller: let controller):
                    return controller.value
                }
            case .change(parent: let parent, logoutRouting: _):
                return parent.value
            case .enableBiometrics(parent: let parent, logoutRouting: _):
                return parent.value
            case .create(parent: let parent):
                return parent.value
            case .createPin(from: let origin):
                switch origin {
                case .foreground(parent: let parent):
                    return parent.value
                case .background: // Only case when there is no parent as the login is the root
                    return nil
                case .attachedOn(controller: let controller):
                    return controller.value
                }
            }
        }
    }

    public enum RoutingType {
        public typealias Forward = (RoutingType.Input) -> Void
        public typealias Backward = () -> Void
        public typealias Logout = () -> Void
        public typealias Effect = (EffectType) -> Void

        public enum Input {
            case authentication(password: String)
            case pin(value: Pin)
            case none

            public var pin: Pin? {
                switch self {
                case .pin(value: let pin):
                    return pin
                default:
                    return nil
                }
            }

            // The decrypted password using the PIN decryption key
            public var password: String? {
                switch self {
                case .authentication(password: let password):
                    return password
                default:
                    return nil
                }
            }
        }

        public enum EffectType {
            case openLink(url: URL)
        }
    }
}

// MARK: CustomDebugStringConvertible

extension PinRouting.Flow: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .foreground:
                return "authentication from foreground"
            case .background:
                return "authentication from background"
            case .attachedOn:
                return "authentication attached to pin hosting controller"
            }
        case .change:
            return "change pin"
        case .enableBiometrics:
            return "enable biometrics"
        case .create,
             .createPin:
            return "create a new pin"
        }
    }
}
