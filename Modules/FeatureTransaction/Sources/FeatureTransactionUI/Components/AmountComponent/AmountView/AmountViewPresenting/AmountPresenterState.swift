// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

/// The `Presenter` state of an `AmountViewable` view.
/// At the time of this writing this includes a `SingleAmountView`
/// and an `AmountTranslationView`.
public enum AmountPresenterState {

    case validInput(ButtonViewModel?)
    case invalidInput(ButtonViewModel?)
}
