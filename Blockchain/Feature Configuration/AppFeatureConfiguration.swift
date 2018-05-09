//
//  AppFeatureConfiguration.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Defines a configuration for a given `AppFeature`
@objc class AppFeatureConfiguration: NSObject {

    @objc let isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}
