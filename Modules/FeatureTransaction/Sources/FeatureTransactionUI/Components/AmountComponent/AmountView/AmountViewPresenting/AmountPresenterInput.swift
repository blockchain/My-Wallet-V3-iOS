// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

/// User input that is inject into an `AmountViewable`
/// using the `connect` API.
public enum AmountPresenterInput {

    /// A character was selected from the keypad
    case input(Character)

    /// A character was deleted
    case delete
}
