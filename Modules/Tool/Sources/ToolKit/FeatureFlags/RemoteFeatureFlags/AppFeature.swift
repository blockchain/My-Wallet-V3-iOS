// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
public enum AppFeature: Int, CaseIterable {

    // MARK: - Firebase features

    /// The announcements
    case announcements

    /// The announcements
    case appUpgradeData

    /// The ticker for the new asset announcement.
    case newAssetAnnouncement

    /// The ticker for the asset rename announcement.
    case assetRenameAnnouncement

    /// Sift Science SDK is enabled
    case siftScienceEnabled

    /// Account Credentials Metadata migration
    case accountCredentialsMetadataMigration

    // MARK: Wallet Connect

    case walletConnectEnabled

    // MARK: Onboarding (After Login)

    /// Shows Email Verification in Onboarding, otherwise just show the buy flow
    case showEmailVerificationInOnboarding

    /// Shows Email Verification, if needed, when a user tries to make a purchase
    case showEmailVerificationInBuyFlow

    // MARK: - SSO

    case unifiedSignIn

    case pollingForEmailLogin

    // MARK: - Transactions

    /// Enables the use of the `/products` endpoint to check users capabilities.
    case productsChecksEnabled

    /// Enable interest withdraw and deposit
    case interestWithdrawAndDeposit

    /// Enable Zen-Desk Messaging for Gold Verified Users
    case customerSupportChat

    /// Enable Open Banking
    case openBanking

    /// Enable New Card Acquirers (Stripe & Checkout)
    case newCardAcquirers

    /// Enable Apple Pay
    case applePay

    /// Enables the use of the hot wallet address for custodial transactions.
    case hotWalletCustodial

    case sendToDomainsAnnouncement

    case blockchainDomains

    // MARK: - Onboarding

    /// New tour view from `FeatureTour`
    case newOnboardingTour

    // MARK: - Card Success Rate

    /// Enables the success rate check of a 6 digit bin when adding a new CC
    case cardSuccessRate

    /// Enables Referral button in Settings
    case referral

    // MARK: - SKAdNetworkAttribution

    case skAdNetworkAttribution

    case staking
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    public var remoteEnabledKey: String {
        switch self {
        case .appUpgradeData:
            return "ios_app_maintenance"
        case .interestWithdrawAndDeposit:
            return "ios_interest_deposit_withdraw"
        case .announcements:
            return "announcements"
        case .newAssetAnnouncement:
            return "new_asset_announcement_ticker"
        case .assetRenameAnnouncement:
            return "rename_asset_announcement_ticker"
        case .siftScienceEnabled:
            return "sift_science_enabled"
        case .showEmailVerificationInOnboarding:
            return "show_email_verification_in_onboarding_ios"
        case .showEmailVerificationInBuyFlow:
            return "show_email_verification_in_buy_flow_ios"
        case .unifiedSignIn:
            return "sso_unified_sign_in_enabled_ios"
        case .pollingForEmailLogin:
            return "ios_ff_sso_polling"
        case .productsChecksEnabled:
            return "ios_products_check_enabled"
        case .customerSupportChat:
            return "customer_support_chat_ios"
        case .openBanking:
            return "ios_open_banking"
        case .newCardAcquirers:
            return "ios_ff_new_card_acquirers"
        case .walletConnectEnabled:
            return "ios_ff_wallet_connect"
        case .newOnboardingTour:
            return "ios_ff_new_onboarding_tour"
        case .hotWalletCustodial:
            return "ios_ff_hot_wallet_custodial"
        case .applePay:
            return "ios_ff_apple_pay"
        case .cardSuccessRate:
            return "ios_ff_card_success_rate"
        case .sendToDomainsAnnouncement:
            return "ios_ff_send_to_domains_announcement"
        case .blockchainDomains:
            return "ios_ff_blockchain_domains"
        case .accountCredentialsMetadataMigration:
            return "ios_ff_account_credentials_metadata_migration"
        case .skAdNetworkAttribution:
            return "ios_ff_skAdNetwork_attribution"
        case .referral:
            return "ios_ff_referral"
        case .staking:
            return "ios_ff_staking_account"
        }
    }

    /// Enables the feature for alpha release by overriding remote config settings.
    var isAlphaReady: Bool {
        switch self {
        case .newAssetAnnouncement:
            return false
        case .assetRenameAnnouncement:
            return false
        case .interestWithdrawAndDeposit:
            return false
        case .appUpgradeData:
            return false
        case .announcements:
            return false
        case .siftScienceEnabled:
            return false
        case .showEmailVerificationInOnboarding:
            return false
        case .showEmailVerificationInBuyFlow:
            return false
        case .unifiedSignIn:
            return false
        case .pollingForEmailLogin:
            return true
        case .productsChecksEnabled:
            return true
        case .customerSupportChat:
            return false
        case .newCardAcquirers:
            return true
        case .cardSuccessRate:
            return true
        case .openBanking:
            return true
        case .walletConnectEnabled:
            return true
        case .newOnboardingTour:
            return true
        case .hotWalletCustodial:
            return false
        case .applePay:
            return false
        case .sendToDomainsAnnouncement:
            return true
        case .blockchainDomains:
            return true
        case .accountCredentialsMetadataMigration:
            return false
        case .skAdNetworkAttribution:
            return true
        case .referral:
            return true
        case .staking:
            return false
        }
    }
}

public struct AssetRenameAnnouncementFeature: Decodable {
    public let networkTicker: String
    public let oldTicker: String
}
