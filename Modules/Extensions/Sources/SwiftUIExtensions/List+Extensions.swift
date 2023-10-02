// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)

import SwiftUI

extension View {
    @ViewBuilder
    public func hideScrollContentBackground() -> some View {
        if #available(iOS 16, *) {
            self.scrollContentBackground(.hidden)
        } else {
            introspectTableView { tableView in
                tableView.backgroundColor = .clear
            }
        }
    }
}

#endif
