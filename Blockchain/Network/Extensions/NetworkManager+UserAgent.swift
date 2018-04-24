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
        let deviceName = UIDevice.current.modelName
        guard
            let version = Bundle.applicationVersion,
            let build = Bundle.applicationBuildVersion else {
                return nil
        }
        let versionAndBuild = String(format: "%@ b%@", version, build)
        return String(format: "Blockchain-iOS/%@ (iOS/%@; %@)", versionAndBuild, systemVersion, deviceName)
    }
}
