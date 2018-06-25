//
//  AppFeature.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc enum AppFeature: Int {
    case biometry
    case swipeToReceive
    case transferFundsFromImportedAddress
}

extension AppFeature {
    // Use CaseIterable once upgraded to Swift 4.2
    static let allFeatures: [AppFeature] = [
        .biometry, .swipeToReceive, .transferFundsFromImportedAddress
    ]
}
