// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension CGRect {
    /// Returns the smaller of two frames, preserving the origin.
    func min(_ frame: CGRect) -> CGRect {
        if width > frame.width || width > frame.height {
            .init(origin: origin, size: frame.size)
        } else {
            self
        }
    }
}
