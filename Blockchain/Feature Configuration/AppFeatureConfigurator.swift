//
//  AppFeatureConfigurator.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Firebase

@objc class AppFeatureConfigurator: NSObject {
    static let shared = AppFeatureConfigurator()

    /// Class function to retrieve the AppFeatureConfigurator shared instance for obj-c compatibility.
    @objc class func sharedInstance() -> AppFeatureConfigurator { return shared }

    private let remoteConfig: RemoteConfig

    private override init() {
        remoteConfig = RemoteConfig.remoteConfig()
        super.init()
        setDefaultConfigs()
    }

    /// Returns an `AppFeatureConfiguration` object for the provided feature.
    ///
    /// - Parameter feature: the feature
    /// - Returns: the configuration for the feature requested
    @objc func configuration(for feature: AppFeature) -> AppFeatureConfiguration {

        // If there is no remote key defined for the feature (i.e. if it is not controlled via Firebase),
        // it is enabled by default
        guard let remoteEnabledKey = feature.remoteEnabledKey else {
            return AppFeatureConfiguration(isEnabled: true)
        }

        let isEnabled = remoteConfig.configValue(forKey: remoteEnabledKey).boolValue
        return AppFeatureConfiguration(isEnabled: isEnabled)
    }

    func initialize() {
        fetchRemoteConfig()
    }

    private func fetchRemoteConfig() {
        let expiration = TimeInterval(6 * 60 * 60) // 6 hours
        remoteConfig.fetch(withExpirationDuration: expiration) { [weak self] status, error in
            guard let strongSelf = self else { return }
            guard status == .success && error == nil else {
                print("config fetch error")
                return
            }
            strongSelf.remoteConfig.activateFetched()
        }
    }

    // MARK: - Private

    private func setDefaultConfigs() {
        remoteConfig.setDefaults([
            AppFeature.stellarAirdrop.remoteEnabledKey!: "false" as NSString
        ])
    }
}
