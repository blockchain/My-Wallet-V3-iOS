// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum FormPresentationState {

    public enum InvalidReason {

        /// Invalid the text with the type of field associated
        case invalidTextField

        /// Empty text field.
        /// This should not be reflected to the end user in most cases
        case emptyTextField

        /// Text fields that have content matching requirement don't match
        case mismatch
    }

    /// Valid state of input with `Values` associated
    case valid

    /// Invalid state of input with `InvalidReason` associated
    case invalid(InvalidReason)

    /// Returns `true` if state is valid
    public var isValid: Bool {
        switch self {
        case .valid:
            true
        case .invalid:
            false
        }
    }

    /// Returns the reason in self is `.invalid`
    public var invalidReason: InvalidReason? {
        switch self {
        case .invalid(let reason):
            reason
        default:
            nil
        }
    }
}
