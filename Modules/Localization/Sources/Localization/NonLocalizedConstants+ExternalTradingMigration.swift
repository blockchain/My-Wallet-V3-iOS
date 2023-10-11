//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension NonLocalizedConstants.ExternalTradingMigration {
    public static let upgradeButton = NSLocalizedString("Upgrade",
                                                 comment: "ExternalTradingMigration: Upgrade")
    public static let learnMoreButton = NSLocalizedString("Learn more",
                                                   comment: "ExternalTradingMigration: Learn more")
    public static let continueButton = NSLocalizedString("Continue",
                                                  comment: "ExternalTradingMigration: Continue")

    public enum TermsAndConditions {
        public static let disclaimer = NSLocalizedString("By checking this box, I hereby agree to the terms and conditions laid out in the Bakkt User Agreement provided above. By agreeing, I understand that the information I am providing will be used to create my new account application to Bakkt Crypto Solutions, LLC and Bakkt Marketplace, LLC for purposes of opening and maintaining an account. Bakkt’s User Agreement.", comment: "ExternalTradingMigration: Bakkt disclaimer")
    }

    public enum Consent {
        public static let headerTitle = NSLocalizedString("We’re upgrading your experience", comment: "ExternalTradingMigration: We’re upgrading your experience")
        public static let headerDescription = NSLocalizedString("As we evolve, we’re partnering with a trusted third-party provider to ensure you continue to enjoy our services seamlessly.", comment: "ExternalTradingMigration: As we evolve, we’re partnering with a trusted third-party provider to ensure you continue to enjoy our services seamlessly.")
        public static let disclaimerItemsToConsolidate = NSLocalizedString("By tapping “Continue”, I hereby agree to the terms and conditions laid out in the Bakkt User Agreement provided below. By so agreeing, I understand that the information I am providing will be used to create my new account application to Bakkt Crypto Solutions, LLC and Bakkt Marketplace, LLC for purposes of opening and maintaining an account. Bakkt’s User Agreement.", comment: "ExternalTradingMigration: Upgrade")
        public static let disclaimerNoItemsToConsolidate = NSLocalizedString("By tapping on “Upgrade”, you authorize Apex Clearing Corporation to provide all information provided to Apex Clearing Corporation in your new account application to Bakkt Crypto Solutions, LLC for purposes of opening and maintaining an Bakkt Crypto Solutions, LLC account. Bakkt’s User Agreement.", comment: "ExternalTradingMigration: Disclaimer")

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

        public  enum SupportedAssets {
            public static let title = NSLocalizedString("Supported Assets", comment: "ExternalTradingMigration: Supported Assets")
            public static let message = NSLocalizedString(
                "Some crypto assets will no longer be supported on your new experience. In case you have balances on any of these, you will be able to consolidate them into either Bitcoin (BTC) or Ethereum (ETH) without any costs involved to ensure your funds remain secure and easily manageable.",
                comment: "ExternalTradingMigration: Updated Message"
            )
        }
    }

    public enum AssetMigration {
        public static let headerTitle = NSLocalizedString("One last step", comment: "ExternalTradingMigration: One last step")

        public static let headerDescription = NSLocalizedString("The following assets are becoming unsupported in our new Terms of Service. We'll consolidate them into Bitcoin for a smoother transition, ensuring your funds remain secure and easily manageable.", comment: "ExternalTradingMigration: The following assets are becoming unsupported in our new Terms of Service. We'll consolidate them into Bitcoin for a smoother transition, ensuring your funds remain secure and easily manageable.")

        public static let disclaimer = NSLocalizedString("Consolidating your assets into Bitcoin (BTC) does not have any costs involved. Supported assets in your balances will remain the same.", comment: "ExternalTradingMigration: Consolidating your assets into Bitcoin (BTC) does not have any costs involved. Supported assets in your balances will remain the same.")
    }

    public enum MigrationInProgress {
        public static let headerTitle = NSLocalizedString("Migration in progress", comment: "ExternalTradingMigration: Migration in progress")

        public static let headerDescription = NSLocalizedString("We are upgrading your account. This process might take up to 24 hours. \n\n During this period, your funds may be temporarily inaccessible. Don’t worry, our team is working diligently to minimize any disruption.", comment: "ExternalTradingMigration: We are upgrading your account. This process might take up to 24 hours. During this period, your funds may be temporarily inaccessible. Don’t worry, our team is working diligently to minimize any disruption.")
        public static let goToDashboard = NSLocalizedString("Go to dashboard", comment: "ExternalTradingMigration: Go to dashboard")
    }
}

extension NonLocalizedConstants.Bakkt {
    public static let bakktStartMigrationWithAssetsTitle = NSLocalizedString(
        "Before you continue trading",
        comment: "Bakkt Migration Title: Before you continue trading"
    )

    public static let bakktStartMigrationWithAssetsMessage = NSLocalizedString(
        "We’re partnering with a trusted third-party provider to ensure you enjoy our services seamlessly. Please, upgrade your account to continue trading crypto.",
        comment: "Bakkt Migration Message: We’re partnering with a trusted third-party provider to ensure you enjoy our services seamlessly. Please, upgrade your account to continue trading crypto."
    )

    public static let bakktStartMigrationNoAssetsTitle = NSLocalizedString(
        "Important information",
        comment: "Bakkt Migration Title: Before you continue trading"
    )

    public static let bakktStartMigrationNoAssetsMessage = NSLocalizedString(
        "We’re partnering with a trusted third-party provider to ensure you enjoy our services seamlessly. Please, review our new Terms of Services to start trading crypto.",
        comment: "Bakkt Migration Message: We’re partnering with a trusted third-party provider to ensure you enjoy our services seamlessly. Please, review our new Terms of Services to start trading crypto."
    )

    public static let bakktUpgradeAccountButton = NSLocalizedString(
        "Upgrade account",
        comment: "Bakkt Migration CTA: Upgrade account"
    )

    public static let bakktReviewTermsButton = NSLocalizedString(
        "Review Terms of Service",
        comment: "Bakkt Migration CTA: Review Terms of Service"
    )

    public static let bakktMigrationInProgressTitle = NSLocalizedString(
        "Migration in progress",
        comment: "Blocked: Title"
    )

    public static let bakktMigrationMessage = NSLocalizedString(
        "We are upgrading your account. This process might take up to 24 hours.",
        comment: "Blocked: We are upgrading your account. This process might take up to 24 hours."
    )

    public static let bakktMigrationSuccessAnnouncementCardTitle = NSLocalizedString(
        "Account sucessfully upgraded",
        comment: "Bakkt Migration: Account sucessfully upgraded"
    )

    public static let bakktMigrationSuccessAnnouncementCardMessage = NSLocalizedString(
        "You're all set up! 🥳\nContinue trading today",
        comment: "Bakkt Migration: You're all set up! 🥳\nContinue trading today"
    )

    public static func depositDisclaimerBakkt() -> String {
        NSLocalizedString(
            "I authorize Bakkt Marketplace, LLC (“Bakkt”) to debit my bank account provided herein on %@, in the amount I entered via ACH, and, if necessary, to make adjustments for any debits made in error to my bank account on this transaction. If I am a customer residing in one of the following states (HI, PR, UT), I grant such authorization to Bakkt Crypto Solutions, LLC. I understand this authorization will remain in full force and effect until I notify Bakkt/Bakkt Crypto Solutions, LLC in writing that I wish to revoke this authorization. I understand that Bakkt/Bakkt Crypto Solutions, LLC requires at least 1 day prior notice in order to cancel this authorization. Terms of the User Agreement apply.",
            comment: "Bakkt disclaimer"
        )
    }

    public static func withdrawDisclaimerBakkt() -> String {
        NSLocalizedString(
            "I authorize Bakkt Marketplace, LLC (“Bakkt”) to credit my bank account provided herein on %@, in the amount I entered via ACH, and, if necessary, to make adjustments for any debits made in error to my bank account on this transaction. If I am a customer residing in one of the following states (HI, PR, UT), I grant such authorization to Bakkt Crypto Solutions, LLC. I understand this authorization will remain in full force and effect until I notify Bakkt/Bakkt Crypto Solutions, LLC in writing that I wish to revoke this authorization. I understand that Bakkt/Bakkt Crypto Solutions, LLC requires at least 1 day prior notice in order to cancel this authorization. Terms of the User Agreement apply.",
            comment: "Bakkt disclaimer"
        )
    }
}


extension NonLocalizedConstants.Bakkt.Checkout {
    public static func buyDisclaimerBakkt() -> String {
        NSLocalizedString(
            "You [authorize]() Bakkt Marketplace, LLC to transfer %@ from your account held at Bakkt Marketplace, LLC to Bakkt Crypto Solutions, LLC to pay for your purchase of %@. The actual quantity of coins purchased may change due to volatility in the price of %@, but your order will be executed based on the best price available to Bakkt Crypto Solutions, LLC.  Cryptocurrency transactions are not FDIC or SIPC insured and cryptocurrencies are not securities.",
            comment: "Bakkt disclaimer"
        )
    }

    public static func sellDisclaimerBakkt() -> String {
        NSLocalizedString(
            "You [authorize]() Bakkt Marketplace, LLC to accept the transfer of funds from Bakkt Crypto Solutions, LLC to your account held at Bakkt Marketplace, LLC to complete your sale of %@.  The actual value sold may change due to volatility in the price of %@, but your order will be executed based on the best price available to Bakkt Crypto Solutions, LLC.  Cryptocurrency transactions are not FDIC or SIPC insured and cryptocurrencies are not securities.",
            comment: "Bakkt disclaimer"
        )
    }

    public static let authorizeTitle = NSLocalizedString(
        "AUTHORIZATION AND LIMITED POWER OF ATTORNEY",
        comment: "Title: AUTHORIZATION AND LIMITED POWER OF ATTORNEY"
    )

    public static let authorizeBody = NSLocalizedString(
        "Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept instructions from Customer to transfer funds from Customer’s account in the specified amount to pay for Customer’s cryptocurrency purchase(s) to an account in the name of Bakkt Crypto Solutions, LLC. These funds will be wired to a Bakkt Crypto Solutions, LLC bank account outside of Blockchain.com and Bakkt Marketplace, LLC’s possession and control, which Customer hereby authorizes. Customer acknowledges that Blockchain.com and Bakkt Marketplace, LLC do not have the ability to monitor or recall the funds after the funds have been wired to the Bakkt Crypto Solutions, LLC bank account. Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept all instructions to deposit funds into Customer’s account from the Bakkt Crypto Solutions, LLC account at the instruction of Bakkt Crypto Solutions, LLC. Customer agrees to hold Blockchain.com and Bakkt Marketplace, LLC harmless in accepting and following instructions from Customer for the transfer of funds from Customer’s account to the Bakkt Crypto Solutions, LLC account and instructions from Bakkt Crypto Solutions, LLC for the transfer of funds into Customer’s account from the Bakkt Crypto Solutions, LLC account. This authorization and limited power of attorney will remain in force for a period of ten year(s) and shall be deemed renewed with each request to transfer money out of or into Customer’s account at Blockchain.com.  Customer may revoke this power of attorney prospectively at any time.",
        comment: "Body: Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept instructions from Customer to transfer funds from Customer’s account in the specified amount to pay for Customer’s cryptocurrency purchase(s) to an account in the name of Bakkt Crypto Solutions, LLC. These funds will be wired to a Bakkt Crypto Solutions, LLC bank account outside of Blockchain.com and Bakkt Marketplace, LLC’s possession and control, which Customer hereby authorizes. Customer acknowledges that Blockchain.com and Bakkt Marketplace, LLC do not have the ability to monitor or recall the funds after the funds have been wired to the Bakkt Crypto Solutions, LLC bank account. Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept all instructions to deposit funds into Customer’s account from the Bakkt Crypto Solutions, LLC account at the instruction of Bakkt Crypto Solutions, LLC. Customer agrees to hold Blockchain.com and Bakkt Marketplace, LLC harmless in accepting and following instructions from Customer for the transfer of funds from Customer’s account to the Bakkt Crypto Solutions, LLC account and instructions from Bakkt Crypto Solutions, LLC for the transfer of funds into Customer’s account from the Bakkt Crypto Solutions, LLC account. This authorization and limited power of attorney will remain in force for a period of ten year(s) and shall be deemed renewed with each request to transfer money out of or into Customer’s account at Blockchain.com.  Customer may revoke this power of attorney prospectively at any time."
    )
}
