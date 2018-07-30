//
//  Reachability.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Reachability {

    /// Checks if the device has internet connectivity
    @objc static func hasInternetConnection() -> Bool {
        let reachability = Reachability.forInternetConnection()
        guard reachability?.currentReachabilityStatus() != NotReachable else {
            Logger.shared.info("No internet connection.")
            return false
        }
        return true
    }
}
