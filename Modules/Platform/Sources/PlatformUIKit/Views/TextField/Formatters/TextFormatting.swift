// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// The result of the text format process
public enum TextFormattingSource {

    /// The text was corrected by the text formater and the new, formated value
    /// is associated
    case formatted(to: String)

    /// The text was not formated by the text formater, so the old text should
    /// be in use
    case original(text: String)

    var isCorrected: Bool {
        switch self {
        case .formatted:
            true
        case .original:
            false
        }
    }
}

public enum TextInputOperation {
    case addition
    case deletion
}

public protocol TextFormatting: AnyObject {
    func format(_ string: String, operation: TextInputOperation) -> TextFormattingSource
}
