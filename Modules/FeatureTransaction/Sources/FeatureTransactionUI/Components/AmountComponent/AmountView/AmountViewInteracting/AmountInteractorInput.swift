// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// User input that is inject into an `AmountViewInteracting`
/// using the `connect` API.
public enum AmountInteractorInput {

    /// Inserting a character
    case insert(Character)

    /// Deleting a character
    case remove

    public var character: Character? {
        switch self {
        case .insert(let value):
            value
        case .remove:
            nil
        }
    }
}
