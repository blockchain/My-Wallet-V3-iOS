// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// This may be renamed but the idea here is that where `AlertActions` or `BottomSheetActions` are built
/// you can define different things that should happen when the action is selected like
/// presenting a URL, executing a block, or receiving any `ActionPayload` if you
/// need some custom behavior.
public enum ActionMetadata {
    case url(URL)
    case block(() -> Void)
    case pop
    case dismiss

    /// Returns the associated block closure (if any)
    public var block: (() -> Void)? {
        switch self {
        case .block(let block):
            block
        default:
            nil
        }
    }
}
