// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain
import FeatureProductsDomain
import MoneyKit
import PlatformKit
import WalletPayloadKit

/// Contains any needed remotely fetched data before displaying announcements.
struct AnnouncementPreliminaryData {

    // MARK: Types

    struct AssetRename {
        let asset: CryptoCurrency
        let oldTicker: String
        let balance: MoneyValue
    }

    // MARK: Properties

    /// User is able to claim free Blockchain.com domain.
    let claimFreeDomainEligible: Bool

    /// Announcement New Asset
    let newAsset: CryptoCurrency?

    /// Announcement Asset Rename
    let assetRename: AssetRename?

    /// The nabu user
    let user: NabuUser

    /// User tiers information
    let tiers: KYC.UserTiers

    var isKycSupported: Bool {
        country?.isKycSupported ?? false
    }

    var hasTwoFA: Bool {
        authenticatorType != .standard
    }

    var hasIncompleteBuyFlow: Bool {
        simpleBuyEventCache[.hasShownBuyScreen] && simpleBuyIsAvailable
    }

    /// Whether the user has a wallet balance in any account.
    let hasAnyWalletBalance: Bool

    let majorProductBlocked: ProductIneligibility?

    let cowboysPromotionIsEnabled: Bool

    let isRecoveryPhraseVerified: Bool

    let walletAwareness: ExchangeWalletAwarenessResponse?

    private let country: CountryData?
    private let simpleBuyIsAvailable: Bool
    private let simpleBuyEventCache: EventCache
    private let authenticatorType: WalletAuthenticatorType

    init(
        assetRename: AssetRename?,
        authenticatorType: WalletAuthenticatorType,
        claimFreeDomainEligible: Bool,
        countries: [CountryData],
        cowboysPromotionIsEnabled: Bool,
        hasAnyWalletBalance: Bool,
        isRecoveryPhraseVerified: Bool,
        majorProductBlocked: ProductIneligibility?,
        newAsset: CryptoCurrency?,
        simpleBuyEventCache: EventCache = resolve(),
        simpleBuyIsAvailable: Bool,
        tiers: KYC.UserTiers,
        user: NabuUser,
        walletAwareness: ExchangeWalletAwarenessResponse?
    ) {
        self.country = countries.first { $0.code == user.address?.countryCode }
        self.assetRename = assetRename
        self.authenticatorType = authenticatorType
        self.claimFreeDomainEligible = claimFreeDomainEligible
        self.cowboysPromotionIsEnabled = cowboysPromotionIsEnabled
        self.hasAnyWalletBalance = hasAnyWalletBalance
        self.isRecoveryPhraseVerified = isRecoveryPhraseVerified
        self.majorProductBlocked = majorProductBlocked
        self.newAsset = newAsset
        self.simpleBuyEventCache = simpleBuyEventCache
        self.simpleBuyIsAvailable = simpleBuyIsAvailable
        self.tiers = tiers
        self.user = user
        self.walletAwareness = walletAwareness
    }
}
