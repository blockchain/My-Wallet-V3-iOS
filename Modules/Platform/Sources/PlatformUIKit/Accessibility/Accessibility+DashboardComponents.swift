// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Accessibility.Identifier {

    public enum CurrentBalanceCell {
        public static let prefix = "CurrentBalance."
        public static let view = "\(prefix)view"
        public static let title = "\(prefix)title"
        public static let description = "\(prefix)description"
        public static let pending = "\(prefix)pending"
    }

    public enum Dashboard {
        private static let prefix = "Dashboard."
        public enum FiatCustodialCell {
            public static let prefix = "\(Dashboard.prefix)FiatCustodialCell."
            public static let currencyName = "\(prefix)currencyName"
            public static let currencyCode = "\(prefix)currencyCode"
            public static let currencyBadgeView = "\(prefix)currencyBadgeView"
            public static let baseFiatBalance = "\(prefix)baseFiatBalance"
            public static let quoteFiatBalance = "\(prefix)quoteFiatBalance"
        }

        public enum Notice {
            private static let prefix = "\(Dashboard.prefix)Notice."
            public static let label = "\(prefix)label"
            public static let imageView = "\(prefix)imageView"
        }

        public enum TotalBalanceCell {
            private static let prefix = "\(Dashboard.prefix)TotalBalanceCell."
            public static let titleLabel = "\(prefix)titleLabel"
            public static let valueLabelSuffix = "\(prefix)total"
            public static let pieChartView = "\(prefix)pieChartView"
        }

        public enum AssetCell {
            private static let prefix = "\(Dashboard.prefix)AssetCell."
            public static let titleLabelFormat = "\(prefix)titleLabel."
            public static let assetImageView = "\(prefix)assetImageView."
            public static let fiatPriceLabelFormat = "\(prefix)fiatPriceLabelFormat."
            public static let changeLabelFormat = "\(prefix)changeLabelFormat."
            public static let fiatBalanceLabelFormat = "\(prefix)fiatBalanceLabel."
            public static let marketFiatBalanceLabelFormat = "\(prefix)marketFiatBalanceLabel."
            public static let cryptoBalanceLabelFormat = "\(prefix)cryptoBalanceLabel."
        }

        enum Announcement {
            private static let prefix = "\(Dashboard.prefix)Announcement."

            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let imageView = "\(prefix)thumbImageView"
            static let dismissButton = "\(prefix)dismissButton"
            static let confirmButton = "\(prefix)confirmButton"
            static let backgroundButton = "\(prefix)backgroundButton"
        }
    }
}
