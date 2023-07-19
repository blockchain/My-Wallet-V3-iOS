// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa

/// API for the `Presentation` layer of an `AmountViewable`.
/// This is used for views on the `Enter Amount` screen.
public protocol AmountViewPresenting {

    /// Used for injecting the user inputs into the `Presentation` layer of an
    /// `AmountViewable`
    /// - Parameter input: User input like adding a character or deleting a character
    func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState>
}
