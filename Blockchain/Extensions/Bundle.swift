//
//  Bundle.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension Bundle {
    /// The application version. Equivalent to CFBundleShortVersionString.
    static var applicationVersion: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let version = infoDictionary["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return version
    }
    /// The build version of the application. Equivalent to CFBundleVersion.
    static var applicationBuildVersion: String? {
        guard let infoDictionary = main.infoDictionary as? [String: String] else {
            return nil
        }
        guard let buildVersion = infoDictionary["CFBundleVersion"] else {
            return nil
        }
        return buildVersion
    }
}
