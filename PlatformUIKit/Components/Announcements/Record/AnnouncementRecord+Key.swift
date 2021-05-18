//
//  AnnouncementRecord+Key.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

extension AnnouncementRecord {
    
    public enum Key: String, CaseIterable {
        
        // MARK: - Persistent

        case walletIntro = "announcement-cache-wallet-intro"
        case verifyEmail = "announcement-cache-email-verification"
        case blockstackAirdropRegisteredMini = "announcement-cache-stx-registered-airdrop-mini"
        case simpleBuyPendingTransaction = "announcement-simple-buy-pending-transaction"
        case simpleBuyKYCIncomplete = "announcement-simple-buy-kyc-incomplete"
        
        // MARK: - Periodic
        
        case backupFunds = "announcement-cache-backup-funds"
        case twoFA = "announcement-cache-2fa"
        case buyBitcoin = "announcement-cache-buy-btc"
        case transferBitcoin = "announcement-cache-transfer-btc"
        case kycAirdrop = "announcement-cache-kyc-airdrop"
        case newSwap = "announcement-cache-new-swap"
        
        // MARK: - One Time

        case aaveYfiDot = "announcement-cache-aave-yfi-dot-received"
        case blockstackAirdropReceived = "announcement-cache-kyc-stx-airdrop-received"
        case identityVerification = "announcement-cache-identity-verification"
        case exchange = "announcement-cache-pit"
        case bitpay = "announcement-cache-bitpay"
        case resubmitDocuments = "announcement-cache-resubmit-documents"
        case fiatFundsKYC = "announcement-cache-fiat-funds-kyc"
        case fiatFundsNoKYC = "announcement-cache-fiat-funds-no-kyc"
        case cloudBackup = "announcement-cache-cloud-backup"
        case interestFunds = "announcement-cache-interest-funds"
    }
    
    @available(*, deprecated, message: "`LegacyKey` was superseded by `Key` and is not being used anymore.")
    enum LegacyKey: String {
        
        case shouldHidePITLinkingCard
        
        var key: Key? {
            switch self {
            case .shouldHidePITLinkingCard:
                return .exchange
            }
        }
    }
}

