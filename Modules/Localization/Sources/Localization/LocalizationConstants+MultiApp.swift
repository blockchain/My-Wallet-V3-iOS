// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum SuperApp {
        public enum AppChrome {}
        public enum Dashboard {
            public enum QuickActions {}
        }

        public enum AllAssets {
            public enum Filter {}
        }

        public enum AllActivity {}
    }
}

extension LocalizationConstants.SuperApp {
    public static let trading = NSLocalizedString(
        "Trading",
        comment: "Trading title"
    )
    public static let pkw = NSLocalizedString(
        "DeFi",
        comment: "DeFi title"
    )
}

extension LocalizationConstants.SuperApp.AppChrome {
    public static let totalBalance = NSLocalizedString(
        "Total Balance",
        comment: "Total Balance title"
    )
}

extension LocalizationConstants.SuperApp.AllAssets {
    public static let title = NSLocalizedString(
        "All assets",
        comment: "All assets"
    )

    public static let searchPlaceholder = NSLocalizedString(
        "Search coin",
        comment: "Search coin"
    )

    public static let cancelButton = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )

    public static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )
}

extension LocalizationConstants.SuperApp.AllActivity {
    public static let title = NSLocalizedString(
        "Activity",
        comment: "Activity"
    )

    public static let searchPlaceholder = NSLocalizedString(
        "Search coin, type or date",
        comment: "Search coin, type or date"
    )

    public static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )

    public static let cancelButton = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )
}

extension LocalizationConstants.SuperApp.AllAssets.Filter {
    public static let title = NSLocalizedString(
        "Filter Assets",
        comment: "Filter Assets"
    )

    public static let showSmallBalancesLabel = NSLocalizedString(
        "Show small balances",
        comment: "Show small balances"
    )

    public static let showButton = NSLocalizedString(
        "Show",
        comment: "Show"
    )

    public static var resetButton = NSLocalizedString(
        "Reset",
        comment: "Reset"
    )
}

extension LocalizationConstants.SuperApp.Dashboard {
    public static let allAssetsLabel = NSLocalizedString(
        "All assets",
        comment: "All assets"
    )

    public static let seeAllLabel = NSLocalizedString(
        "See all",
        comment: "See all"
    )
}

extension LocalizationConstants.SuperApp.Dashboard.QuickActions {
    public static let more = NSLocalizedString(
        "More",
        comment: "More"
    )
}
