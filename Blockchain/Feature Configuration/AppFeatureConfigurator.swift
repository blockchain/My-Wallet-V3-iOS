//
//  AppFeatureConfigurator.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AppFeatureConfigurator: NSObject {
    static let shared = AppFeatureConfigurator()

    /// Class function to retrieve the AppFeatureConfigurator shared instance for obj-c compatibility.
    @objc class func sharedInstance() -> AppFeatureConfigurator { return shared }

    private var featureToConfigurations = [AppFeature: AppFeatureConfiguration]()

    private override init() {
        super.init()
        // Enable all features by default
        AppFeature.allFeatures.forEach {
            featureToConfigurations[$0] = AppFeatureConfiguration(isEnabled: true)
        }
    }

    /// Returns an `AppFeatureConfiguration` object for the provided feature.
    ///
    /// - Parameter feature: the feature
    /// - Returns: the configuration for the feature requested
    @objc func configuration(for feature: AppFeature) -> AppFeatureConfiguration? {
        return featureToConfigurations[feature]
    }
}
