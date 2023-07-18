// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureSettingsDomain
import Localization
import SwiftUI

struct ThemeSettingsView: View {
    typealias L10n = LocalizationConstants.Settings

    @BlockchainApp var app

    @State var currentSelection: DarkModeSetting = .automatic

    var body: some View {
        List {
            ForEach(DarkModeSetting.allCases, id: \.id) { value in
                row(value)
                    .adjustListSeparatorInset()
            }
        }
        .hideScrollContentBackground()
        .navigationTitle(L10n.theme)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                IconButton(
                    icon: Icon.closeCircle.with(length: 20.pt)
                ) {
                    app.post(event: blockchain.ux.settings.theme.settings.entry.paragraph.button.icon.tap)
                }
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .bindings {
            subscribe($currentSelection.animation(), to: blockchain.app.settings.theme.mode)
        }
        .batch {
            set(blockchain.ux.settings.theme.settings.entry.paragraph.button.icon.tap.then.close, to: true)
        }
    }

    func row(_ value: DarkModeSetting) -> some View {
        TableRow(
            leading: { value.icon.iconColor(.semantic.title) },
            title: { TableRowTitle(value.title) },
            trailing: {
                Icon.check
                    .with(length: 20.pt)
                    .iconColor(.semantic.primary)
                    .opacity(value == currentSelection ? 1.0 : 0.0)
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            app.state.set(blockchain.app.settings.theme.mode, to: value)
        }
        .tableRowHorizontalInset(0)
        .tableRowVerticalInset(10)
        .listRowBackground(Color.semantic.background)
        .listRowSeparatorTint(Color.semantic.light)
    }
}

extension View {
    @ViewBuilder
    func adjustListSeparatorInset() -> some View {
        if #available(iOS 16.0, *) {
            self.alignmentGuide(.listRowSeparatorLeading) { dimensions in
                dimensions[.leading]
            }
        } else {
            self.introspectTableView(customize: { tableView in
                tableView.separatorInset = .zero
            })
        }
    }
}

extension DarkModeSetting: Identifiable {
    public var id: String {
        rawValue
    }

    var icon: Icon {
        switch self {
        case .light:
            return Icon.sun.with(length: 20.pt)
        case .dark:
            return Icon.moon.with(length: 20.pt)
        case .automatic:
            return Icon.settings.with(length: 20.pt)
        }
    }
}
