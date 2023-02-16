// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

extension AnnouncementRecord {

    /// A key used to register this Announcement history
    /// All keys must be prefixed by `"announcement-"`
    public enum Key {
        case applePay
        case assetRename(code: String)
        case backupFunds
        case buyBitcoin
        case claimFreeCryptoDomain
        case claimFreeCryptoDomainKYC
        case majorProductBlocked
        case newAsset(code: String)
        case resubmitDocuments
        case resubmitDocumentsAfterRecovery
        case sddUsersFirstBuy
        case simpleBuyKYCIncomplete
        case transferBitcoin
        case twoFA
        case verifyEmail
        case verifyIdentity
        case viewNFTWaitlist
        case walletConnect
        case exchangeCampaign

        var string: String {
            let prefix = "announcement-"

            let key: String
            switch self {
            case .applePay:
                key = "apple-pay"
            case .assetRename(let code):
                key = "cache-asset-rename-\(code)"
            case .backupFunds:
                key = "cache-backup-funds"
            case .buyBitcoin:
                key = "cache-buy-btc"
            case .claimFreeCryptoDomain:
                key = "claim-free-crypto-domain"
            case .claimFreeCryptoDomainKYC:
                key = "claim-free-crypto-domain-kyc"
            case .majorProductBlocked:
                key = "cache-major-product-blocked"
            case .newAsset(let code):
                key = "cache-new-asset-\(code)"
            case .resubmitDocuments:
                key = "cache-resubmit-documents"
            case .resubmitDocumentsAfterRecovery:
                key = "cache-resubmit-documents-after-recovery"
            case .sddUsersFirstBuy:
                key = "cache-sdd-users-buy"
            case .simpleBuyKYCIncomplete:
                key = "simple-buy-kyc-incomplete"
            case .transferBitcoin:
                key = "cache-transfer-btc"
            case .twoFA:
                key = "cache-2fa"
            case .verifyEmail:
                key = "cache-email-verification"
            case .verifyIdentity:
                key = "cache-identity-verification"
            case .viewNFTWaitlist:
                key = "view-nft-waitlist"
            case .walletConnect:
                key = "wallet-connect"
            case .exchangeCampaign:
                key = "exchange-campaign"
            }

            return prefix + key
        }
    }
}
