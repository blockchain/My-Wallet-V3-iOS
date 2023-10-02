// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants.ExternalTradingMigration {
    static let upgradeButton = NSLocalizedString("Upgrade", comment: "ExternalTradingMigration: Upgrade")
    static let learnMoreButton = NSLocalizedString("Learn more", comment: "ExternalTradingMigration: Learn more")
    static let continueButton = NSLocalizedString("Continue", comment: "ExternalTradingMigration: Continue")

    public enum TermsAndConditions {
        static let disclaimer = NSLocalizedString("By checking this box, I hereby agree to the terms and conditions laid out in the Bakkt User Agreement provided above. By agreeing, I understand that the information I am providing will be used to create my new account application to Bakkt Crypto Solutions, LLC and Bakkt Marketplace, LLC for purposes of opening and maintaining an account. Bakkt’s User Agreement.", comment: "ExternalTradingMigration: Bakkt disclaimer")
    }

    public enum Consent {
        static let headerTitle = NSLocalizedString("We’re upgrading your experience", comment: "ExternalTradingMigration: We’re upgrading your experience")
        static let headerDescription = NSLocalizedString("As we evolve, we’re partnering with a trusted third-party provider to ensure you continue to enjoy our services seamlessly.", comment: "ExternalTradingMigration: As we evolve, we’re partnering with a trusted third-party provider to ensure you continue to enjoy our services seamlessly.")
        static let disclaimerItemsToConsolidate = NSLocalizedString("By tapping “Continue”, I hereby agree to the terms and conditions laid out in the Bakkt User Agreement provided below. By so agreeing, I understand that the information I am providing will be used to create my new account application to Bakkt Crypto Solutions, LLC and Bakkt Marketplace, LLC for purposes of opening and maintaining an account. Bakkt’s User Agreement.", comment: "ExternalTradingMigration: Upgrade")
        static let disclaimerNoItemsToConsolidate = NSLocalizedString("By tapping on “Upgrade”, you authorize Apex Clearing Corporation to provide all information provided to Apex Clearing Corporation in your new account application to Bakkt Crypto Solutions, LLC for purposes of opening and maintaining an Bakkt Crypto Solutions, LLC account. Bakkt’s User Agreement.", comment: "ExternalTradingMigration: Disclaimer")

        public enum EnchancedTransactions {
            public static let title = NSLocalizedString("Enhanced transactions", comment: "ExternalTradingMigration: Enhanced transactions")
            public static let message = NSLocalizedString(
                "Once the migration is complete, you’ll regain the ability to buy and sell assets as well as deposit and withdraw FIAT currency. However, please note that the option to withdraw crypto assets will no longer be available.",
                comment: "ExternalTradingMigration: Once the migration is complete, you’ll regain the ability to buy and sell assets as well as deposit and withdraw FIAT currency. However, please note that the option to withdraw crypto assets will no longer be available."
            )
        }

        public enum MigrationPeriod {
            public static let title = NSLocalizedString("Migration period", comment: "ExternalTradingMigration: Migration period")
            public static let message = NSLocalizedString(
                "The migration process will take up to 24 hours to complete and won’t be possible to cancel once accepted. During this period, your funds may be temporarily inaccessible. Rest assured, our team is working diligently to minimize any disruption.",
                comment: "ExternalTradingMigration: The migration process will take up to 24 hours to complete and won’t be possible to cancel once accepted. During this period, your funds may be temporarily inaccessible. Rest assured, our team is working diligently to minimize any disruption."
            )
        }

        public enum HistoricalData {
            public static let title = NSLocalizedString("Historical data", comment: "ExternalTradingMigration: Historical data")
            public static let message = NSLocalizedString(
                "Please be aware that historical data currently available on our platform will become inaccessible after the migration. We recommend saving any important data you wish to retain.",
                comment: "ExternalTradingMigration: Updated Message"
            )
        }

        public enum DefiWallet {
            public static let title = NSLocalizedString("Defi Wallet", comment: "ExternalTradingMigration: Defi Wallet")
            public static let message = NSLocalizedString(
                "You won’t experience any changes with your DeFi Wallet.",
                comment: "ExternalTradingMigration: You won’t experience any changes with your DeFi Wallet."
            )
        }

        public enum SupportedAssets {
            public static let title = NSLocalizedString("Supported Assets", comment: "ExternalTradingMigration: Supported Assets")
            public static let message = NSLocalizedString(
                "Some crypto assets will no longer be supported on your new experience. In case you have balances on any of these, you will be able to consolidate them into either Bitcoin (BTC) or Ethereum (ETH) without any costs involved to ensure your funds remain secure and easily manageable.",
                comment: "ExternalTradingMigration: Updated Message"
            )
        }
    }

    public enum AssetMigration {
        static let headerTitle = NSLocalizedString("One last step", comment: "ExternalTradingMigration: One last step")

        static let headerDescription = NSLocalizedString("The following assets are becoming unsupported in our new Terms of Service. We'll consolidate them into Bitcoin for a smoother transition, ensuring your funds remain secure and easily manageable.", comment: "ExternalTradingMigration: The following assets are becoming unsupported in our new Terms of Service. We'll consolidate them into Bitcoin for a smoother transition, ensuring your funds remain secure and easily manageable.")

        static let disclaimer = NSLocalizedString("Consolidating your assets into Bitcoin (BTC) does not have any costs involved. Supported assets in your balances will remain the same.", comment: "ExternalTradingMigration: Consolidating your assets into Bitcoin (BTC) does not have any costs involved. Supported assets in your balances will remain the same.")
    }

    public enum MigrationInProgress {
        static let headerTitle = NSLocalizedString("Migration in progress", comment: "ExternalTradingMigration: Migration in progress")

        static let headerDescription = NSLocalizedString("We are upgrading your account. This process might take up to 24 hours. \n\n During this period, your funds may be temporarily inaccessible. Don’t worry, our team is working diligently to minimize any disruption.", comment: "ExternalTradingMigration: We are upgrading your account. This process might take up to 24 hours. During this period, your funds may be temporarily inaccessible. Don’t worry, our team is working diligently to minimize any disruption.")
        static let goToDashboard = NSLocalizedString("Go to dashboard", comment: "ExternalTradingMigration: Go to dashboard")
    }
}
