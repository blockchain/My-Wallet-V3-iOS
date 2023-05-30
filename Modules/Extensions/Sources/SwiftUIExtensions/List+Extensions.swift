// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    @ViewBuilder
    public func hideScrollContentBackground() -> some View {
        if #available(iOS 16, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self.introspectTableView { tableView in
                tableView.backgroundColor = .clear
            }
        }
    }

    @ViewBuilder
    public func listRowSeparatorColor(_ color: Color) -> some View {
        if #available(iOS 15, *) {
            self.listRowSeparatorTint(color)
        } else {
            self.introspectTableView { tableView in
                tableView.separatorColor = UIColor(color)
            }
        }
    }
}
