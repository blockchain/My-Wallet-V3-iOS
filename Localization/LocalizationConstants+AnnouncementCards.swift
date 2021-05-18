//
//  LocalizationConstants+AnnouncementCards.swift
//  Localization
//
//  Created by Paulo on 08/01/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

import Foundation

extension LocalizationConstants {

    public enum AnnouncementCards {

        // MARK: - Persistent

        public enum Welcome {
            public static let title = NSLocalizedString(
                "Welcome to Blockchain!",
                comment: "Welcome announcement card title"
            )
            public static let description = NSLocalizedString(
                "Here are a few tips to get your account up and running, we’ll also help you make sure everything is secure.",
                comment: "Welcome announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Tell Me More",
                comment: "Welcome announcement card CTA button title"
            )
            public static let skipButton = NSLocalizedString(
                "Maybe Later",
                comment: "Welcome announcement card skip button title"
            )
        }
        public enum VerifyEmail {
            public static let title = NSLocalizedString(
                "Verify Your Email Address",
                comment: "Verify email announcement card title"
            )
            public static let description = NSLocalizedString(
                "You need to confirm your email address so that we can keep you informed about your wallet.",
                comment: "Verify email announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Verify Email Address",
                comment: "Verify email announcement card CTA button title"
            )
        }
        public enum BackupFunds {
            public static let title = NSLocalizedString(
                "Wallet Recovery Phrase",
                comment: "Backup funds announcement card title"
            )
            public static let description = NSLocalizedString(
                "You control your crypto. Write down your recovery phrase to restore all your funds in case you lose your password.",
                comment: "Backup funds announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Backup Phrase",
                comment: "Backup funds announcement card CTA button title"
            )
        }
        public enum SimpleBuyPendingTransaction {
            public static let titlePrefix = NSLocalizedString(
                "Pending",
                comment: "Simple Buy Pending Transaction announcement card title"
            )
            public static let titleSuffix = NSLocalizedString(
                "Buy",
                comment: "Simple Buy Pending Transaction announcement card title"
            )
            public static let descriptionPrefix = NSLocalizedString(
                "Once we receive your bank transfer, your",
                comment: "Simple Buy Pending Transaction announcement card description prefix"
            )
            public static let descriptionSuffix = NSLocalizedString(
                "buy order will complete",
                comment: "Simple Buy Pending Transaction announcement card description suffix"
            )
            public static var ctaButton: String {
                SimpleBuy.Checkout.Button.transferDetails
            }
        }
        public enum SimpleBuyFinishSignup {
            public static let title = NSLocalizedString(
                "Finish Signing Up. Buy Crypto.",
                comment: "Simple Buy KYC Incomplete announcement card title"
            )
            public static let description = NSLocalizedString(
                "You’re almost done signing up for your Blockchain.com Wallet. Once you finish and get approved, start buying crypto.",
                comment: "Simple Buy KYC Incomplete announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Continue",
                comment: "Simple Buy KYC Incomplete announcement card CTA button title"
            )
        }

        // MARK: - One time

        public enum BlockstackAirdropReceived {
            public static let title = NSLocalizedString(
                "Your Airdrop has landed",
                comment: "STX airdrop received announcement card title"
            )
            public static let description = NSLocalizedString(
                "Your Stacks are now in your wallet. We’ll let you know as soon as these are available to be used.",
                comment: "STX airdrop received announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "View Details",
                comment: "STX airdrop received announcement card CTA button title"
            )
        }
        public enum BlockstackAirdropRegisteredMini {
            public static let title = NSLocalizedString(
                "A Reward for Being Gold Level",
                comment: "STX airdrop registered announcement mini card title"
            )
            public static let description = NSLocalizedString(
                "We're airdropping you free crypto in 2020",
                comment: "STX airdrop registered announcement mini card description"
            )
        }
        public enum IdentityVerification {
            public static let title = NSLocalizedString(
                "Finish Verifying Your Account",
                comment: "Finish identity verification announcement card title"
            )
            public static let description = NSLocalizedString(
                "Pick up where you left off and complete your identity verification.",
                comment: "Finish identity verification announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Continue Verification",
                comment: "Finish identity verification announcement card CTA button title"
            )
        }
        public enum AaveYfiDot {
            public static let title = NSLocalizedString(
                "Aave, DeFi and DOT available!",
                comment: "Aave Yfi Dot announcement card title"
            )
            public static let description = NSLocalizedString(
                "Aave, DeFi and Polkadot tokens are now available to Buy, Sell, Swap and Send in your Wallet.",
                comment: "Aave Yfi Dot announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Check Them Out",
                comment: "Aave Yfi Dot announcement card CTA button title"
            )
        }
        public enum CloudBackup {
            public static let title = NSLocalizedString(
                "Introducing Cloud Backups",
                comment: "Cloud Backup announcement card title"
            )
            public static let description = NSLocalizedString(
                "You can now backup your wallet securely to the cloud. You can opt-out of backups in your wallet settings.",
                comment: "Cloud Backup announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Learn more",
                comment: "Cloud Backup announcement card CTA button title"
            )
        }
        public enum Exchange {
            public static let title = NSLocalizedString(
                "Introducing the Exchange",
                comment: "Exchange announcement card title"
            )
            public static let description = NSLocalizedString(
                "It's time to Level Up to a better crypto exchange. Buy, sell, and trade more digital assets in the Blockchain.com Exchange.",
                comment: "Exchange announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Checkout the Exchange",
                comment: "Exchange announcement card CTA button title"
            )
        }
        public enum CashIdentityVerification {
            public static let title = NSLocalizedString("Keep Cash in Your Wallet", comment: "Keep Cash in Your Wallet")
            public static let description = NSLocalizedString(
                "Verify your identity to deposit cash into the Wallet and buy crypto.",
                comment: "Verify your identity to deposit cash into the Wallet and buy crypto."
            )
            public static let badgeName = NSLocalizedString("NEW", comment: "NEW")
            public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
        }
        public enum InterestIdentityVerification {
            public static let title = NSLocalizedString("Earn 9.0% Interest", comment: "Earn 4.5% Interest")
            public enum Description {
                public static let kycd = NSLocalizedString(
                    "Start earning up to 9.0% interest on your crypto.",
                    comment: "Start earning up to 9.0% interest on your crypto."
                )
                public static let notKYCd = NSLocalizedString(
                    "Verify your identity and start earning up to 9.0% interest on your crypto.",
                    comment: "Verify your identity and start earning up to 9.0% interest on your crypto."
                )
            }
            public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
        }
        public enum FiatFundsLinkBank {
            public static let title = NSLocalizedString("Link a Bank to Buy Crypto", comment: "Link a Bank to Buy Crypto")
            public static let description = NSLocalizedString(
                "Hold cash in your Blockchain.com Wallet. Deposit and Withdraw at anytime.",
                comment: "Hold cash in your Blockchain.com Wallet. Deposit and Withdraw at anytime."
            )
            public static let linkABank = NSLocalizedString("Link a Bank", comment: "Link a Bank")
        }
        public enum Bitpay {
            public static let description = NSLocalizedString(
                "With BitPay, you can now use your Blockchain wallet for purchases with supporting retailers.",
                comment: "Bitpay announcement card description"
            )
        }

        // MARK: - Periodic

        public enum BuyBitcoin {
            public static let title = NSLocalizedString(
                "Buy Crypto",
                comment: "Buy BTC announcement card title"
            )
            public static let description = NSLocalizedString(
                "We can help you buy in just a few simple steps.",
                comment: "Buy BTC announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Buy Crypto Now",
                comment: "Buy BTC announcement card CTA button title"
            )
        }
        public enum NewSwap {
            public enum Promo {
                public static let title = NSLocalizedString(
                    "Swap Faster. Cheaper. Better.",
                    comment: ""
                )
                public static let description = NSLocalizedString(
                    "Upgrade to Gold and Swap faster, with higher limits, lower fees, and a better experience.",
                    comment: ""
                )
                public static let ctaButton = NSLocalizedString(
                    "Upgrade now",
                    comment: ""
                )
            }
            public enum Eligible {
                public static let title = NSLocalizedString(
                    "Swap it like it’s hot.",
                    comment: ""
                )
                public static let description = NSLocalizedString(
                    "Faster. Cheaper. Better. Our new Swap experience lets you exchange crypto in fewer taps.",
                    comment: ""
                )
                public static let ctaButton = NSLocalizedString(
                    "Swap Now",
                    comment: ""
                )
            }
            public enum NotEligible {
                public static let title = NSLocalizedString(
                    "Swap better.",
                    comment: ""
                )
                public static let description = NSLocalizedString(
                    "We’ve updated Swap with a new look and better experience.",
                    comment: ""
                )
                public static let ctaButton = NSLocalizedString(
                    "Swap Now",
                    comment: ""
                )
            }
        }
        public enum Swap {
            public static let title = NSLocalizedString(
                "Trade Crypto",
                comment: "Swap announcement card title"
            )
            public static let description = NSLocalizedString(
                "Trade one crypto for another without giving up control of your keys. Get competitive, real-time prices and fast on-chain settlement.",
                comment: "Swap announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Check out Swap",
                comment: "Swap announcement card CTA button title"
            )
        }
        public enum TransferInCrypto {
            public static let title = NSLocalizedString(
                "Transfer In Crypto",
                comment: "Transfer crypto announcement card title"
            )
            public static let description = NSLocalizedString(
                "Deposit crypto in your wallet to get started. It's the best way to store your crypto while keeping control of your keys.",
                comment: "Transfer crypto announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Get Started",
                comment: "Transfer crypto announcement card CTA button title"
            )
        }
        public enum ResubmitDocuments {
            public static let title = NSLocalizedString(
                "Documents Needed",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
            )
            public static let description = NSLocalizedString(
                "We had some issues with the documents you’ve supplied. Please try uploading the documents again to continue with your verification.",
                comment: "The description on the announcement card for when a user needs to submit documents to verify their identity."
            )
            public static let ctaButton = NSLocalizedString(
                "Upload Documents",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
            )
        }
        public enum KycAirdrop {
            public static let title = NSLocalizedString(
                "Want Free Crypto?",
                comment: "Kyc airdrop announcement card title"
            )
            public static let description = NSLocalizedString(
                "Verify your identity to participate in our Airdrop program and receive free crypto from future Airdrops.",
                comment: "Kyc airdrop announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Start Verification",
                comment: "Kyc airdrop announcement card CTA button title"
            )
        }
        public enum TwoFA {
            public static let title = NSLocalizedString(
                "Enable 2-Step Verification",
                comment: "2FA announcement card title"
            )
            public static let description = NSLocalizedString(
                "Protect your wallet from unauthorized access by enabling 2-Step Verification.",
                comment: "2FA announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Enable 2-Step Verification",
                comment: "2FA announcement card CTA button title"
            )
        }
    }
}
