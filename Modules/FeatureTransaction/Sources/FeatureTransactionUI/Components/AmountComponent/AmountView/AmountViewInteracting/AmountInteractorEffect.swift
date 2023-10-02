// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// An effect returned from an `AmountViewInteracting`.
/// This is used with `AmountViewable` views.
public enum AmountInteractorEffect {

    /// A failure state happened. Used to show an alert.
    case failure(error: Error)

    /// No-op
    case none
}
