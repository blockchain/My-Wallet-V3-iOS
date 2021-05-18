//
//  AppFeature.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc
public enum AppFeature: Int, CaseIterable {
    case biometry
    case swipeToReceive
    case transferFundsFromImportedAddress

    /// Exchange linking enabled
    case exchangeLinking

    /// Exchange announcement visibility
    case exchangeAnnouncement

    /// The announcements
    case announcements

    /// Is simple buy enabled
    case simpleBuyEnabled

    /// Is simple buy card payment method enabled
    case simpleBuyCardsEnabled

    /// Is simple buy funds payment method enabled
    case simpleBuyFundsEnabled
    
    /// Is interest account enabled
    case interestAccountEnabled

    /// Is Send 2.0 enabled
    case newSendEnabled

    case wDGLDenabled

    case siftScienceEnabled

    case achEnabled

    case achBuyFlowEnabled

    case achSettingsEnabled
    
    /// Sending from custodial to non-custodial
    /// via the transaction flow
    case internalSendEnabled

    /// Enable Secure Channel
    case secureChannel
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    public var remoteEnabledKey: String? {
        switch self {
        case .exchangeLinking:
            return "pit_linking_enabled"
        case .exchangeAnnouncement:
            return "pit_show_announcement"
        case .announcements:
            return "announcements"
        case .simpleBuyEnabled:
            return "simple_buy_enabled"
        case .simpleBuyCardsEnabled:
            return "simple_buy_method_card_enabled"
        case .simpleBuyFundsEnabled:
            return "simple_buy_method_funds_enabled"
        case .interestAccountEnabled:
            return "interest_account_enabled"
        case .newSendEnabled:
            return "new_send_enabled_ios"
        case .wDGLDenabled:
            return "wdgld_enabled"
        case .siftScienceEnabled:
            return "sift_science_enabled"
        case .achEnabled:
            return "ach_enabled"
        case .achBuyFlowEnabled:
            return "ach_buy_flow_enabled_ios"
        case .achSettingsEnabled:
            return "ach_settings_enabled_ios"
        case .internalSendEnabled:
            return "internal_send_enabled_ios"
        case .secureChannel:
            // TODO: (paulo) Modern Wallet P3 - Use "secure_channel_ios".
            return "secure_channel_ios_dev"
        case .biometry,
             .swipeToReceive,
             .transferFundsFromImportedAddress:
            return nil
        }
    }
}
