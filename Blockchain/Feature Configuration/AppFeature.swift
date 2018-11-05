//
//  AppFeature.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc enum AppFeature: Int, CaseIterable {
    case biometry
    case swipeToReceive
    case transferFundsFromImportedAddress
    case stellar
    case stellarAirdrop
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    var remoteEnabledKey: String? {
        switch self {
        case .stellarAirdrop:
            return "ios_sunriver_airdrop_enabled"
        default:
            return nil
        }
    }
}
