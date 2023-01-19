// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

/// The announcement types as defined remotely
public enum AnnouncementType: String, Codable {
    case applePay = "apple_pay"
    case assetRename = "asset_rename"
    case backupFunds = "backup_funds"
    case buyBitcoin = "buy_btc"
    case claimFreeCryptoDomain = "claim_free_crypto_domain"
    case claimFreeCryptoDomainKYC = "claim_free_crypto_domain_kyc"
    case majorProductBlocked = "major_product_blocked"
    case newAsset = "new_asset"
    case resubmitDocuments = "kyc_resubmit"
    case resubmitDocumentsAfterRecovery = "kyc_recovery_resubmission"
    case sddUsersFirstBuy = "sdd_users_buy"
    case simpleBuyKYCIncomplete = "sb_finish_signup"
    case transferBitcoin = "transfer_btc"
    case twoFA = "two_fa"
    case verifyEmail = "verify_email"
    case verifyIdentity = "kyc_incomplete"
    case viewNFTWaitlist = "view_nft_waitlist"
    case walletConnect = "wallet_connect"
    case exchangeCampaign = "exchange_campaign"

    /// The key identifying the announcement in cache
    var key: AnnouncementRecord.Key {
        switch self {
        case .applePay:
            return .applePay
        case .backupFunds:
            return .backupFunds
        case .buyBitcoin:
            return .buyBitcoin
        case .claimFreeCryptoDomain:
            return .claimFreeCryptoDomain
        case .claimFreeCryptoDomainKYC:
            return .claimFreeCryptoDomainKYC
        case .majorProductBlocked:
            return .majorProductBlocked
        case .resubmitDocuments:
            return .resubmitDocuments
        case .resubmitDocumentsAfterRecovery:
            return .resubmitDocumentsAfterRecovery
        case .sddUsersFirstBuy:
            return .sddUsersFirstBuy
        case .simpleBuyKYCIncomplete:
            return .simpleBuyKYCIncomplete
        case .transferBitcoin:
            return .transferBitcoin
        case .twoFA:
            return .twoFA
        case .verifyEmail:
            return .verifyEmail
        case .verifyIdentity:
            return .verifyIdentity
        case .viewNFTWaitlist:
            return .viewNFTWaitlist
        case .walletConnect:
            return .walletConnect
        case .newAsset:
            if BuildFlag.isInternal {
                unimplemented("AnnouncementType.newAsset does not have a default key.")
            }
            return .newAsset(code: "")
        case .assetRename:
            if BuildFlag.isInternal {
                unimplemented("AnnouncementType.assetRename does not have a default key.")
            }
            return .assetRename(code: "")
        case .exchangeCampaign:
            return .exchangeCampaign
        }
    }

    public var showsWhenWalletHasNoBalance: Bool {
        switch self {
        case .claimFreeCryptoDomain,
             .claimFreeCryptoDomainKYC,
             .exchangeCampaign:
            return true
        default:
            return false
        }
    }
}
