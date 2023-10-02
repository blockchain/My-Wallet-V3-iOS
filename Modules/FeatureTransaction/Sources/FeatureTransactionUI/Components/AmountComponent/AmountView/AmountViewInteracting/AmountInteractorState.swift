// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

/// The `Interactor` state of an `AmountViewable` view.
/// At the time of this writing this includes a `SingleAmountView`
/// and an `AmountTranslationView`.
public enum AmountInteractorState {

    public enum MessageState {
        /// Shows no message.
        case none

        /// Shows an info message.
        case info(message: String)

        /// Shows a warning.
        case warning(message: String)

        /// Shows an error message
        case error(message: String)
    }

    case validInput(MessageState)
    case invalidInput(MessageState)
}
