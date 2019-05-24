//
//  UserAgent.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension NetworkManager {
    static var userAgent: String? {
        let systemVersion = UIDevice.current.systemVersion
        guard
            let version = Bundle.applicationVersion,
            let build = Bundle.applicationBuildVersion else {
                return nil
        }
        let versionAndBuild = String(format: "%@ b%@", version, build)
        return String(format: "Blockchain-iOS/%@ (iOS/%@; %@)", versionAndBuild, systemVersion)
    }
}

@objc
extension Bundle {
    /// The application version. Equivalent to CFBundleShortVersionString.
    public static var applicationVersion: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let version = infoDictionary["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return version
    }
    /// The build version of the application. Equivalent to CFBundleVersion.
    public static var applicationBuildVersion: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let buildVersion = infoDictionary["CFBundleVersion"] as? String else {
            return nil
        }
        return buildVersion
    }
}
