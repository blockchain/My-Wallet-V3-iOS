//
//  AppFeature.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc enum AppFeature: Int, RawValued {
    case touchId
    case swipeToReceive
    case transferFundsFromImportedAddress
}
