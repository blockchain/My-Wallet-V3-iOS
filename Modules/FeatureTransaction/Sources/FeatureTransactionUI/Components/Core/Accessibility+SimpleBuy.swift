// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

extension Accessibility.Identifier {

    public enum SimpleBuy {

        enum PaymentMethodsScreen {
            private static let prefix = "PaymentMethods."
            static let addCard = "\(prefix)AddCard"
            static let addBank = "\(prefix)AddBank"
            static let bankTransfer = "\(prefix)BankTransfer"
            static let linkedBank = "\(prefix)LinkedBank"
            static let useApplePay = "\(prefix)ApplePay"
        }

        public enum TransferDetails {
            private static let prefix = "TransferDetails."
            public static let lineItemPrefix = prefix
            public static let titleLabel = "\(prefix)titleLabel"
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let disclaimerLabel = "\(prefix)disclaimerLabel"
            public static let disclaimerImage = "\(prefix)disclaimerImage"
        }

        public enum KYCScreen {
            public static let titleLabel = "titleLabel"
            public static let subtitleLabel = "subtitleLabel"
            public static let goToWalletButton = "goToWalletButton"
        }
    }
}
